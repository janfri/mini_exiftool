#
# MiniExiftool
#
# This library is wrapper for the Exiftool command-line
# application (http://www.sno.phy.queensu.ca/~phil/exiftool/)
# written by Phil Harvey.
# Read and write access is done in a clean OO manner.
#
# Author: Jan Friedrich
# Copyright (c) 2007 by Jan Friedrich
# Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, 
# Version 2.1, February 1999
#

require 'fileutils'
require 'tempfile'
require 'tmpdir'
require 'pstore'
require 'set'

# Simple OO access to the Exiftool command-line application.
class MiniExiftool

  # Name of the Exiftool command-line application
  @@cmd = 'exiftool'

  attr_reader :filename
  attr_accessor :numerical, :composite, :errors

  VERSION = '0.4.0'

  # opts support at the moment
  # * <code>:numerical</code> for numerical values, default is +false+
  # * <code>:composite</code> for including composite tags while loading,
  #   default is +false+
  def initialize filename, opts={}
    std_opts = {:numerical => false, :composite => false}
    opts = std_opts.update opts
    @numerical = opts[:numerical]
    @composite = opts[:composite]
    @values = TagHash.new
    @tag_names = TagHash.new
    @changed_values = TagHash.new
    @errors = TagHash.new
    load filename
  end

  # Load the tags of filename.
  def load filename
    if filename.nil? || !File.exist?(filename)
      raise MiniExiftool::Error.new("File '#{filename}' does not exist.")
    elsif File.directory?(filename)
      raise MiniExiftool::Error.new("'#{filename}' is a directory.")
    end
    @filename = filename
    @values.clear
    @tag_names.clear
    @changed_values.clear
    opt_params = ''
    opt_params << (@numerical ? '-n ' : '')
    opt_params << (@composite ? '' : '-e ')
    cmd = %Q(#@@cmd -q -q -s -t #{opt_params} "#{filename}")
    if run(cmd)
      parse_output
    else
      raise MiniExiftool::Error.new(@error_text)
    end
    self
  end

  # Reload the tags of an already readed file.
  def reload
    load @filename
  end

  # Returns the value of a tag.
  def [] tag
    @changed_values[tag] || @values[tag]
  end

  # Set the value of a tag.
  def []=(tag, val)
    @changed_values[tag] = val
  end

  # Returns true if any tag value is changed or if the value of a
  # given tag is changed.
  def changed? tag=false
    if tag
      @changed_values.include? tag
    else
      !@changed_values.empty?
    end
  end

  # Revert all changes or the change of a given tag.
  def revert tag=nil
    if tag
      val = @changed_values.delete(tag)
      res = val != nil
    else
      res = @changed_values.size > 0
      @changed_values.clear
    end
    res
  end

  # Returns an array of the tags (original tag names) of the readed file.
  def tags
    @values.keys.map { |key| @tag_names[key] }
  end

  # Returns an array of all changed tags.
  def changed_tags
    @changed_values.keys.map { |key| MiniExiftool.original_tag(key) }
  end

  # Save the changes to the file.
  def save
    return false if @changed_values.empty?
    @errors.clear
    temp_file = Tempfile.new('mini_exiftool')
    temp_file.close
    temp_filename = temp_file.path
    FileUtils.cp filename, temp_filename
    all_ok = true
    @changed_values.each do |tag, val|
      original_tag = MiniExiftool.original_tag(tag)
      converted_val = convert val
      opt_params = converted_val.kind_of?(Numeric) ? '-n' : ''
      cmd = %Q(#@@cmd -q -P -overwrite_original #{opt_params} -#{original_tag}="#{converted_val}" "#{temp_filename}")
      result = run(cmd)
      unless result
        all_ok = false
        @errors[tag] = @error_text.gsub(/Nothing to do.\n\z/, '').chomp
      end
    end
    if all_ok
      FileUtils.cp temp_filename, filename
      reload
    end
    temp_file.delete
    all_ok
  end
  
  # Returns the command name of the called Exiftool application.
  def self.command
    @@cmd
  end

  # Setting the command name of the called Exiftool application.
  def self.command= cmd
    @@cmd = cmd
  end

  # Returns a set of all known tags of Exiftool.
  def self.all_tags
    unless defined? @@all_tags
      @@all_tags = pstore_get :all_tags
    end
    @@all_tags
  end

  # Returns a set of all possible writable tags of Exiftool.
  def self.writable_tags
    unless defined? @@writable_tags
      @@writable_tags = pstore_get :writable_tags
    end
    @@writable_tags
  end

  # Returns the original Exiftool name of the given tag
  def self.original_tag tag
    unless defined? @@all_tags_map
      @@all_tags_map = pstore_get :all_tags_map
    end
    @@all_tags_map[tag]
  end

  # Returns the version of the Exiftool command-line application.
  def self.exiftool_version
    output = `#{MiniExiftool.command} -ver 2>&1`
    unless $?.exitstatus == 0
      raise MiniExiftool::Error.new("Command '#{MiniExiftool.command}' not found")
    end
    output.chomp!
  end

  def self.unify tag
    tag.gsub(/[-_]/,'').downcase
  end

  ############################################################################
  private
  ############################################################################

  @@error_file = Tempfile.new 'errors'
  @@error_file.close

  def run cmd
    if $DEBUG
      $stderr.puts cmd
    end
    @output = `#{cmd} 2>#{@@error_file.path}`
    @status = $?
    unless @status.exitstatus == 0
      @error_text = File.readlines(@@error_file.path).join
      return false
    else
      @error_text = ''
      return true
    end
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
    if tag_name.sub!(/=$/, '')
      self[tag_name] = args.first
    else
      self[tag_name]
    end
  end

  def parse_output
    @output.each_line do |line|
      tag, value = parse_line line
      @tag_names[tag] = tag
      @values[tag] = value
    end
  end

  def parse_line line
    if line =~ /^([^\t]+)\t(.*)$/
      tag, value = $1, $2
      case value
      when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d$/
        arr = value.split /[: ]/
        arr.map! {|elem| elem.to_i}
        value = Time.local *arr
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
      temp_file.close
      FileUtils.cp(@filename, temp_file.path)
      @temp_filename = temp_file.path
    end
    @temp_filename
  end

  def self.pstore_get attribute
    load_or_create_pstore unless defined? @@pstore
    result = nil
    @@pstore.transaction(true) do |ps|
      result = ps[attribute]
    end
    result
  end

  def self.load_or_create_pstore
    filename = File.join(Dir.tmpdir, 'exiftool_tags_' + exiftool_version.gsub('.', '_'))
    @@pstore = PStore.new filename
    if !File.exist?(filename) || File.size(filename) == 0
      @@pstore.transaction do |ps|
        ps[:all_tags] = all_tags = determine_tags('list')
        ps[:writable_tags] = determine_tags('listw')
        map = {}
        all_tags.each { |k| map[unify(k)] = k }
        ps[:all_tags_map] = map
      end
    end
  end

  def self.determine_tags arg
    lines = `#{@@cmd} -#{arg}`
    tags = Set.new
    lines.each do |line|
      next unless line =~ /^\s/
      tags |= line.chomp.split
    end
    tags
  end


  # Hash with indifferent access: 
  # DateTimeOriginal == datetimeoriginal == date_time_original
  class TagHash < Hash # :nodoc:
    def[] k
      super(unify(k))
    end
    def []= k, v
      super(unify(k), v)
    end
    def delete k
      super(unify(k))
    end

    def unify tag
      MiniExiftool.unify tag
    end
  end
  

  # Exception class
  class MiniExiftool::Error < StandardError; end

end

# Test if we can run the Exiftool command
MiniExiftool.exiftool_version
