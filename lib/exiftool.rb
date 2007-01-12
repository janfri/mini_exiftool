require 'fileutils'
require 'tempfile'

class Exiftool

  class Exiftool::Error < Exception; end

  ProgramName = 'exiftool'

  attr_reader :filename
  attr_accessor :numerical

  def initialize filename, numerical=false
    @prog = ProgramName
    @numerical = numerical
    load filename
  end

  def load filename
    raise Exiftool::Error unless File.exists? filename
    @filename = filename
    @values = {}
    @tag_names = {}
    @changed_values = {}
    opt_params = @numerical ? '-n' : ''
    cmd = %Q(#@prog -e -q -q -s -t #{opt_params} "#{filename}")
    if run(cmd)
      parse_output
    else
      raise Exiftool::Error
    end
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

  def temp_filename
    unless @temp_filename
      temp_file = Tempfile.new('exiftool')
      FileUtils.cp(@filename, temp_file.path)
      @temp_filename = temp_file.path
    end
    @temp_filename
  end

  def tags
    @values.keys.map { |key| @tag_names[key] }
  end

  def changed_tags
    @changed_values.keys.map { |key| @tag_names[key] }
  end

  def save
    @changed_values.each do |tag, val|
      unified_tag = unify tag
      converted_val = convert val
      opt_params = converted_val.kind_of?(Numeric) ? '-n' : ''
      cmd = %Q(#@prog -q -q -P -overwrite_original #{opt_params} -#{unified_tag}="#{converted_val}" "#{filename}")
      run(cmd)
    end
    reload
  end
  
  private

  def run cmd
    @output = `#{cmd}`
    @status = $?
    @status.exitstatus == 0
  end

  def self.unify name
    name.gsub(/_/, '').downcase
  end

  def unify name
    Exiftool.unify name
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
      tag, value = Exiftool.parse_line line
      unified_tag = unify tag
      @tag_names[unified_tag] = tag
      @values[unified_tag] = value
    end
  end

  def self.parse_line line
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
      raise Exiftool::Error
    end
    return [tag, value]
  end

  # Access via class methods

  def self.method_missing symbol, *args
    prog = ProgramName
    tag = unify symbol.to_s
    cmd = %Q(#{prog} -e -q -q -s -t -#{tag} "#{args.first}")
    output = `#{cmd}`
    status = $?
    return nil unless status.exitstatus == 0
    parse_line(output).last
  end

end
