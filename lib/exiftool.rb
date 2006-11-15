class Exiftool

  class Exiftool::Error < RuntimeError
  end

  ProgramName = 'exiftool'

  attr_reader :filename, :hash

  def initialize filename
    @prog = ProgramName
    @tags = {}
    @changed_tags = {}
    @filename = filename
    cmd = "#@prog -n -s -t \"#{filename}\"" 
    if run(cmd)
      parse_output
    else
      raise Exiftool::Error
    end
  end

  def [] key
    @changed_tags[key] || 
      @changed_tags[to_camel key] || 
      @changed_tags[key.upcase] ||

      @tags[key] || 
      @tags[to_camel key] || 
      @tags[key.upcase]
  end

  def []= key, val
    @changed_tags[key] = val
  end

  private

  def run cmd
    @output = `#{cmd}`
    @status = $?
    $?.exitstatus == 0
  end

  def to_camel name
    (name.split(/_/).map { |e| e.capitalize! }).join ''
  end

  def method_missing method_id
    self[method_id.id2name]
  end

  def parse_output
    @output.each_line do |line|
      if line =~ /^(\w+?)\t(.*)$/
        tag, value = $1, $2
        case value
        when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d$/
          value = Time.local(* (value.split /: /))
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
        @tags[tag] = value
      else
        raise Exiftool::Error
      end
    end
  end
  
end
