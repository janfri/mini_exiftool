require 'fileutils'
require 'tempfile'

class Exiftool

  class Exiftool::Error < RuntimeError; end

  ProgramName = 'exiftool'

  attr_reader :filename

  def initialize filename
    @prog = ProgramName
    @filename = filename
    load
  end

  def load
    @values = {}
    @tag_names = {}
    @changed_values = {}
    cmd = %Q(#@prog -e -n -q -q -s -t "#{filename}")
    if run(cmd)
      parse_output
    else
      raise Exiftool::Error
    end
  end

  alias reload load

  def [] tag
    unified_tag = unify tag
    @changed_values[unified_tag] || @values[unified_tag]
  end

  def []=(tag, val)
    unified_tag = unify tag
    converted_val = convert val
    cmd = %Q(#@prog -n -q -q -P -overwrite_original -#{unified_tag}="#{converted_val}" "#{temp_filename}")
    if run(cmd)
      @changed_values[unified_tag] = val
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
      cmd = %Q(#@prog -n -q -q -P -overwrite_original -#{unified_tag}="#{converted_val}" "#{filename}")
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

  def unify name
    name.gsub(/_/, '').downcase
  end

  def convert val
    case val
    when Time
      val = val.strftime('%Y:%m:%d %H:%M:%S')
    when Float
      val = val.to_s
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
        when /^(\d+)x(\d+)$/
          value = [$1, $2]
        when /^[\d ]+$/
          value = value.split(/ /)
        end
        unified_tag = unify tag
        @tag_names[unified_tag] = tag
        @values[unified_tag] = value
      else
        raise Exiftool::Error
      end
    end
  end

end
