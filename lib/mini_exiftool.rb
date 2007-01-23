#
# MiniExiftool
#
# This library is wrapper for the Exiftool command-line
# application (http://www.sno.phy.queensu.ca/~phil/exiftool/)
# written by Phil Harvay.
# Read and write access is done in a clean OO manner.
#
# Author: Jan Friedrich
# Copyright (c) 2007 by Jan Friedrich
# Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, 
# Version 2.1, February 1999
#

require 'fileutils'
require 'open3'
require 'tempfile'

# Simple OO access to the Exiftool command-line application.
class MiniExiftool

  # Name of the exiftool command
  ProgramName = 'exiftool'

  attr_reader :filename
  attr_accessor :numerical

  Version = '0.1.0'

  # opts at the moment only support :numerical for numerical values
  # (the -n parameter in the command line)
  def initialize filename, *opts
    @prog = ProgramName
    @numerical = opts.include? :numerical
    load filename
  end

  def load filename
    raise MiniExiftool::Error unless File.exists? filename
    @filename = filename
    @values = {}
    @tag_names = {}
    @changed_values = {}
    opt_params = @numerical ? '-n' : ''
    cmd = %Q(#@prog -e -q -q -s -t #{opt_params} "#{filename}")
    if run(cmd)
      parse_output
    else
      raise MiniExiftool::Error
    end
    self
  end

  def reload
    load @filename
  end

  def [] tag
    unified_tag = unify tag
    @changed_values[unified_tag] || @values[unified_tag]
  end

  def []=(tag, val)
    unified_tag = unify tag
    converted_val = convert val
    opt_params = converted_val.kind_of?(Numeric) ? '-n' : ''
    cmd = %Q(#@prog -q -q -P -overwrite_original #{opt_params} -#{unified_tag}="#{converted_val}" "#{temp_filename}")
    if run(cmd)
      @changed_values[unified_tag] = val
    end
  end

  def changed? tag=false
    if tag
      @changed_values.include? tag
    else
      !@changed_values.empty?
    end
  end

  def revert tag=nil
    if tag
      unified_tag = unify tag
      val = @changed_values.delete(unified_tag)
      res = val != nil
    else
      res = @changed_values.size > 0
      @changed_values.clear
    end
    res
  end

  def tags
    @values.keys.map { |key| @tag_names[key] }
  end

  def changed_tags
    @changed_values.keys.map { |key| @tag_names[key] }
  end

  def save
    result = false
    @changed_values.each do |tag, val|
      unified_tag = unify tag
      converted_val = convert val
      opt_params = converted_val.kind_of?(Numeric) ? '-n' : ''
      cmd = %Q(#@prog -q -q -P -overwrite_original #{opt_params} -#{unified_tag}="#{converted_val}" "#{filename}")
      run(cmd)
      result = true
    end
    reload
    result
  end
  
  private

  def run cmd
    @output = `#{cmd}`
    @status = $?
    @status.exitstatus == 0
  end

  def unify name
    name.gsub(/_/, '').downcase
  end

  def convert val
    case val
    when Time
      val = val.strftime('%Y:%m:%d %H:%M:%S')
    end
    val
  end

  def method_missing symbol, *args
    tag_name = symbol.id2name
    if tag_name =~ /=$/
      self[tag_name.gsub(/=$/, '')] = args.first
    else
      self[tag_name]
    end
  end

  def parse_output
    @output.each_line do |line|
      tag, value = parse_line line
      unified_tag = unify tag
      @tag_names[unified_tag] = tag
      @values[unified_tag] = value
    end
  end

  def parse_line line
    if line =~ /^(\w+?)\t(.*)$/
      tag, value = $1, $2
      case value
      when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d$/
        value = Time.local(* (value.split /[: ]/))
      when /^\d+\.\d+$/
        value = value.to_f
      when /^0+[1-9]+$/
        # nothing => String
      when /^-?\d+$/
        value = value.to_i
      when /^[\d ]+$/
        value = value.split(/ /)
      end
    else
      raise MiniExiftool::Error
    end
    return [tag, value]
  end

  def temp_filename
    unless @temp_filename
      temp_file = Tempfile.new('mini-exiftool')
      FileUtils.cp(@filename, temp_file.path)
      @temp_filename = temp_file.path
    end
    @temp_filename
  end

  class MiniExiftool::Error < Exception; end

end
