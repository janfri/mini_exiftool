# -- encoding: utf-8 --
#
# MiniExiftool
#
# This library is wrapper for the ExifTool command-line
# application (http://www.sno.phy.queensu.ca/~phil/exiftool/)
# written by Phil Harvey.
# Read and write access is done in a clean OO manner.
#
# Author: Jan Friedrich
# Copyright (c) 2007-2016 by Jan Friedrich
# Licensed under the GNU LESSER GENERAL PUBLIC LICENSE,
# Version 2.1, February 1999
#

require 'fileutils'
require 'json'
require 'open3'
require 'pstore'
require 'rational'
require 'rbconfig'
require 'set'
require 'tempfile'
require 'time'

# Simple OO access to the ExifTool command-line application.
class MiniExiftool

  VERSION = '2.7.6'

  # Name of the ExifTool command-line application
  @@cmd = 'exiftool'

  # Hash of the standard options used when call MiniExiftool.new
  @@opts = { :numerical => false, :composite => true, :fast => false, :fast2 => false,
             :ignore_minor_errors => false, :replace_invalid_chars => false,
             :timestamps => Time }

  # Encoding of the filesystem (filenames in command line)
  @@fs_enc = Encoding.find('filesystem')

  def self.opts_accessor *attrs
    attrs.each do |a|
      define_method a do
        @opts[a]
      end
      define_method "#{a}=" do |val|
        @opts[a] = val
      end
    end
  end

  attr_reader :filename, :errors, :io

  opts_accessor :numerical, :composite, :ignore_minor_errors,
    :replace_invalid_chars, :timestamps

  @@encoding_types = %w(exif iptc xmp png id3 pdf photoshop quicktime aiff mie vorbis)

  def self.encoding_opt enc_type
    (enc_type.to_s + '_encoding').to_sym
  end

  @@encoding_types.each do |enc_type|
    opts_accessor encoding_opt(enc_type)
  end

  # +filename_or_io+ The kind of the parameter is determined via duck typing:
  # if the argument responds to +to_str+ it is interpreted as filename, if it
  # responds to +read+ it is interpreted es IO instance.
  #
  # <b>ATTENTION:</b> If using an IO instance writing of meta data is not supported!
  #
  # +opts+ support at the moment
  # * <code>:numerical</code> for numerical values, default is +false+
  # * <code>:composite</code> for including composite tags while loading,
  #   default is +true+
  # * <code>:ignore_minor_errors</code> ignore minor errors (See -m-option
  #   of the exiftool command-line application, default is +false+)
  # * <code>:coord_format</code> set format for GPS coordinates (See
  #   -c-option of the exiftool command-line application, default is +nil+
  #   that means exiftool standard)
  # * <code>:fast</code> useful when reading JPEGs over a slow network connection
  #   (See -fast-option of the exiftool command-line application, default is +false+)
  # * <code>:fast2</code> useful when reading JPEGs over a slow network connection
  #   (See -fast2-option of the exiftool command-line application, default is +false+)
  # * <code>:replace_invalid_chars</code> replace string for invalid
  #   UTF-8 characters or +false+ if no replacing should be done,
  #   default is +false+
  # * <code>:timestamps</code> generating DateTime objects instead of
  #   Time objects if set to <code>DateTime</code>, default is +Time+
  #
  #   <b>ATTENTION:</b> Time objects are created using <code>Time.local</code>
  #   therefore they use <em>your local timezone</em>, DateTime objects instead
  #   are created <em>without timezone</em>!
  # * <code>:exif_encoding</code>, <code>:iptc_encoding</code>,
  #   <code>:xmp_encoding</code>, <code>:png_encoding</code>,
  #   <code>:id3_encoding</code>, <code>:pdf_encoding</code>,
  #   <code>:photoshop_encoding</code>, <code>:quicktime_encoding</code>,
  #   <code>:aiff_encoding</code>, <code>:mie_encoding</code>,
  #   <code>:vorbis_encoding</code> to set this specific encoding (see
  #   -charset option of the exiftool command-line application, default is
  #   +nil+: no encoding specified)
  def initialize filename_or_io=nil, opts={}
    @opts = @@opts.merge opts
    if @opts[:convert_encoding]
      warn 'Option :convert_encoding is not longer supported!'
      warn 'Please use the String#encod* methods.'
    end
    @filename = nil
    @io = nil
    @values = TagHash.new
    @changed_values = TagHash.new
    @errors = TagHash.new
    load filename_or_io unless filename_or_io.nil?
  end

  def initialize_from_hash hash # :nodoc:
    set_values hash
    set_opts_by_heuristic
    self
  end

  def initialize_from_json json # :nodoc:
    @output = json
    @errors.clear
    parse_output
    self
  end

  # Load the tags of filename or io.
  def load filename_or_io
    if filename_or_io.respond_to? :to_str # String-like
      unless filename_or_io && File.exist?(filename_or_io)
        raise MiniExiftool::Error.new("File '#{filename_or_io}' does not exist.")
      end
      if File.directory?(filename_or_io)
        raise MiniExiftool::Error.new("'#{filename_or_io}' is a directory.")
      end
      @filename = filename_or_io.to_str
    elsif filename_or_io.respond_to? :read # IO-like
      @io = filename_or_io
      @filename = '-'
    else
      raise MiniExiftool::Error.new("Could not open filename_or_io.")
    end
    @values.clear
    @changed_values.clear
    params = '-j '
    params << (@opts[:numerical] ? '-n ' : '')
    params << (@opts[:composite] ? '' : '-e ')
    params << (@opts[:coord_format] ? "-c \"#{@opts[:coord_format]}\"" : '')
    params << (@opts[:fast] ? '-fast ' : '')
    params << (@opts[:fast2] ? '-fast2 ' : '')
    params << generate_encoding_params
    if run(cmd_gen(params, @filename))
      parse_output
    else
      raise MiniExiftool::Error.new(@error_text)
    end
    self
  end

  # Reload the tags of an already read file.
  def reload
    load @filename
  end

  # Returns the value of a tag.
  def [] tag
    @changed_values[tag] || @values[tag]
  end

  # Set the value of a tag.
  def []= tag, val
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

  # Returns an array of the tags (original tag names) of the read file.
  def tags
    @values.keys.map { |key| MiniExiftool.original_tag(key) }
  end

  # Returns an array of all changed tags.
  def changed_tags
    @changed_values.keys.map { |key| MiniExiftool.original_tag(key) }
  end

  # Save the changes to the file.
  def save
    if @io
      raise MiniExiftool::Error.new('No writing support when using an IO.')
    end
    return false if @changed_values.empty?
    @errors.clear
    temp_file = Tempfile.new('mini_exiftool')
    temp_file.close
    temp_filename = temp_file.path
    FileUtils.cp filename.encode(@@fs_enc), temp_filename
    all_ok = true
    @changed_values.each do |tag, val|
      original_tag = MiniExiftool.original_tag(tag)
      arr_val = val.kind_of?(Array) ? val : [val]
      arr_val.map! {|e| convert_before_save(e)}
      params = '-q -P -overwrite_original '
      params << (arr_val.detect {|x| x.kind_of?(Numeric)} ? '-n ' : '')
      params << (@opts[:ignore_minor_errors] ? '-m ' : '')
      params << generate_encoding_params
      arr_val.each do |v|
        params << %Q(-#{original_tag}=#{escape(v)} )
      end
      result = run(cmd_gen(params, temp_filename))
      unless result
        all_ok = false
        @errors[tag] = @error_text.gsub(/Nothing to do.\n\z/, '').chomp
      end
    end
    if all_ok
      FileUtils.cp temp_filename, filename.encode(@@fs_enc)
      reload
    end
    temp_file.delete
    all_ok
  end

  def save!
    unless save
      err = []
      @errors.each do |key, value|
        err << "(#{key}) #{value}"
      end
      raise MiniExiftool::Error.new("MiniExiftool couldn't save. The following errors occurred: #{err.empty? ? "None" : err.join(", ")}")
    end
  end

  def copy_tags_from(source_filename, tags)
    @errors.clear
    unless File.exist?(source_filename)
      raise MiniExiftool::Error.new("Source file #{source_filename} does not exist!")
    end
    params = '-q -P -overwrite_original '
    tags_params = Array(tags).map {|t| '-' << t.to_s}.join(' ')
    cmd = [@@cmd, params, '-tagsFromFile', escape(source_filename).encode(@@fs_enc), tags_params.encode('UTF-8'), escape(filename).encode(@@fs_enc)].join(' ')
    cmd.force_encoding('UTF-8')
    result = run(cmd)
    reload
    result
  end

  # Returns a hash of the original loaded values of the MiniExiftool
  # instance.
  def to_hash
    result = {}
    @values.each do |k,v|
      result[MiniExiftool.original_tag(k)] = v
    end
    result
  end

  # Returns a YAML representation of the original loaded values of the
  # MiniExiftool instance.
  def to_yaml
    to_hash.to_yaml
  end

  # Create a MiniExiftool instance from a hash. Default value
  # conversions will be applied if neccesary.
  def self.from_hash hash, opts={}
    instance = MiniExiftool.new nil, opts
    instance.initialize_from_hash hash
    instance
  end

  # Create a MiniExiftool instance from JSON data. Default value
  # conversions will be applied if neccesary.
  def self.from_json json, opts={}
    instance = MiniExiftool.new nil, opts
    instance.initialize_from_json json
    instance
  end

  # Create a MiniExiftool instance from YAML data created with
  # MiniExiftool#to_yaml
  def self.from_yaml yaml, opts={}
    MiniExiftool.from_hash YAML.load(yaml), opts
  end

  # Returns the command name of the called ExifTool application.
  def self.command
    @@cmd
  end

  # Setting the command name of the called ExifTool application.
  def self.command= cmd
    @@cmd = cmd
  end

  # Returns the options hash.
  def self.opts
    @@opts
  end

  # Returns a set of all known tags of ExifTool.
  def self.all_tags
    unless defined? @@all_tags
      @@all_tags = pstore_get :all_tags
    end
    @@all_tags
  end

  # Returns a set of all possible writable tags of ExifTool.
  def self.writable_tags
    unless defined? @@writable_tags
      @@writable_tags = pstore_get :writable_tags
    end
    @@writable_tags
  end

  # Returns the original ExifTool name of the given tag
  def self.original_tag tag
    unless defined? @@all_tags_map
      @@all_tags_map = pstore_get :all_tags_map
    end
    @@all_tags_map[tag]
  end

  # Returns the version of the ExifTool command-line application.
  def self.exiftool_version
    Open3.popen3 "#{MiniExiftool.command} -ver" do |_inp, out, _err, _thr|
      out.read.chomp!
    end
  rescue SystemCallError
    raise MiniExiftool::Error.new("Command '#{MiniExiftool.command}' not found")
  end

  def self.unify tag
    tag.to_s.gsub(/[-_]/,'').downcase
  end

  @@running_on_windows = /mswin|mingw|cygwin/ === RbConfig::CONFIG['host_os']

  def self.pstore_dir
    unless defined? @@pstore_dir
      # This will hopefully work on *NIX and Windows systems
      home = ENV['HOME'] || ENV['HOMEDRIVE'] + ENV['HOMEPATH'] || ENV['USERPROFILE']
      subdir = @@running_on_windows ? '_mini_exiftool' : '.mini_exiftool'
      @@pstore_dir = File.join(home, subdir)
    end
    @@pstore_dir
  end

  def self.pstore_dir= dir
    @@pstore_dir = dir
  end

  # Exception class
  class MiniExiftool::Error < StandardError; end

  ############################################################################
  private
  ############################################################################

  def cmd_gen arg_str='', filename
    [@@cmd, arg_str.encode('UTF-8'), escape(filename.encode(@@fs_enc))].map {|s| s.force_encoding('UTF-8')}.join(' ')
  end

  def run cmd
    if $DEBUG
      $stderr.puts cmd
    end
    status = Open3.popen3(cmd) do |inp, out, err, thr|
      if @io
        begin
          IO.copy_stream @io, inp
        rescue Errno::EPIPE
          # Output closed, no problem
        rescue ::IOError => e
          raise MiniExiftool::Error.new("IO is not readable.")
        end
        inp.close
      end
      @output = out.read
      @error_text = err.read
      thr.value.exitstatus
    end
    status == 0
  end

  def convert_before_save val
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
    adapt_encoding
    set_values JSON.parse(@output).first
  end

  def adapt_encoding
    @output.force_encoding('UTF-8')
    if @opts[:replace_invalid_chars] && !@output.valid_encoding?
      @output.encode!('UTF-16le', invalid: :replace, replace: @opts[:replace_invalid_chars]).encode!('UTF-8')
    end
  end

  def convert_after_load tag, value
    return value unless value.kind_of?(String)
    return value unless value.valid_encoding?
    case value
    when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d/
      s = value.sub(/^(\d+):(\d+):/, '\1-\2-')
      begin
        if @opts[:timestamps] == Time
          value = Time.parse(s)
        elsif @opts[:timestamps] == DateTime
          value = DateTime.parse(s)
        else
          raise MiniExiftool::Error.new("Value #{@opts[:timestamps]} not allowed for option timestamps.")
        end
      rescue ArgumentError
        value = false
      end
    when /^\+\d+\.\d+$/
      value = value.to_f
    when /^0+[1-9]+$/
      # nothing => String
    when /^-?\d+$/
      value = value.to_i
    when %r(^(\d+)/(\d+)$)
      value = Rational($1.to_i, $2.to_i) rescue value
    when /^[\d ]+$/
      # nothing => String
    end
    value
  end

  def set_values hash
    hash.each_pair do |tag,val|
      @values[tag] = convert_after_load(tag, val)
    end
    # Remove filename specific tags use attr_reader
    # MiniExiftool#filename instead
    # Cause: value of tag filename and attribute
    # filename have different content, the latter
    # holds the filename with full path (like the
    # sourcefile tag) and the former the basename
    # of the filename also there is no official
    # "original tag name" for sourcefile
    %w(directory filename sourcefile).each do |t|
      @values.delete(t)
    end
  end

  def set_opts_by_heuristic
    @opts[:composite] = tags.include?('ImageSize')
    @opts[:numerical] = self.file_size.kind_of?(Integer)
    @opts[:timestamps] = self.FileModifyDate.kind_of?(DateTime) ? DateTime : Time
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
    FileUtils.mkdir_p(pstore_dir)
    pstore_filename = File.join(pstore_dir, 'exiftool_tags_' << exiftool_version.gsub('.', '_') << '.pstore')
    @@pstore = PStore.new pstore_filename
    if !File.exist?(pstore_filename) || File.size(pstore_filename) == 0
      $stderr.puts 'Generating cache file for ExifTool tag names. This takes a few seconds but is only needed once...'
      @@pstore.transaction do |ps|
        ps[:all_tags] = all_tags = determine_tags('list')
        ps[:writable_tags] = determine_tags('listw')
        map = {}
        all_tags.each { |k| map[unify(k)] = k }
        ps[:all_tags_map] = map
      end
      $stderr.puts 'Cache file generated.'
    end
  end

  def self.determine_tags arg
    output = `#{@@cmd} -#{arg}`
    lines = output.split(/\n/)
    tags = Set.new
    lines.each do |line|
      next unless line =~ /^\s/
      tags |= line.chomp.split
    end
    tags
  end

  if @@running_on_windows
    def escape val
      '"' << val.to_s.gsub(/([\\"])/, "\\\\\\1") << '"'
    end
  else
    def escape val
      '"' << val.to_s.gsub(/([\\"$])/, "\\\\\\1") << '"'
    end
  end

  def generate_encoding_params
    params = ''
    @@encoding_types.each do |enc_type|
      if enc_val = @opts[MiniExiftool.encoding_opt(enc_type)]
        params << "-charset #{enc_type}=#{enc_val} "
      end
    end
    params
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

end
