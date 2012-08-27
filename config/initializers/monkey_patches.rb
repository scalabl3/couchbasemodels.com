class Hash

  # if key doesn't exist, returns false
  # if self[key] == false, returns false
  # if self[key] == nil, empty, or blank, returns false
  # if self[key] exists and self[key] == true, or evaluates to true, returns true
  def has_key_and_value? (key)
    return false unless has_key?(key)
    return false if self[key].nil?
    return false if self[key].respond_to?(:empty?) && self[key].empty?
    return false if self[key].respond_to?(:blank) && self[key].blank?
    self[key]
  end

  def to_struct(struct_name)

    #Rails.logger.debug("struct_name class = #{struct_name.class}")

    unless struct_name.is_a? String
      struct_name = struct_name.to_s
    end

    #Rails.logger.debug("struct_name = #{struct_name}")

    #Rails.logger.debug("struct_name class = #{struct_name.class}")


    m = struct_name.scan(/\w+/)
    #Rails.logger.debug("match_data = #{m.inspect}")
    #Rails.logger.debug("match_count = #{m.size}")

    i = 0
    struct = nil
    if m.size > 1
      #Rails.logger.debug("m[#{i}] = #{m[i]}")
      struct = Object.const_get(m[i])
    else
      #Rails.logger.debug("m[#{i}] = #{m[i]}")
      struct = Object.const_get(m[i]).new
    end

    i += 1

    while i < m.size - 1
      #Rails.logger.debug("m[#{i}] = #{m[i]}")
      struct = struct.const_get(m[i])
      i += 1
    end

    if m.size > 1
      #Rails.logger.debug("m[#{i}] = #{m[i]}")
      struct = struct.const_get(m[i]).new
    end


    each do |k,v|
      struct[k] = v
    end
    #puts struct
    #Struct.new(struct_name, *keys).new(*values) #=> Generic Struct, dynamically created
    struct
  end
end

# create accessors that return the calling-method-name and this-method-name
module Kernel
  private
  def this_method
    caller[0] =~ /`([^']*)'/ and $1
  end
  def calling_method
    caller[1] =~ /`([^']*)'/ and $1
  end
end


# pretty print an module's methods to console, with color
class Module
  # Print object's methods
  def pm(*options)
    methods = self.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = self.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name, args, klass]
    end
    max_name = data.collect {|item| item[0].to_s.size}.max
    max_args = data.collect {|item| item[1].to_s.size}.max
    data.each do |item|
      print " #{ANSI_BOLD}#{item[0].to_s.rjust(max_name)}#{ANSI_RESET}"
      print "#{ANSI_GRAY}#{item[1].to_s.ljust(max_args)}#{ANSI_RESET}"
      print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
    end
    data.size
  end
end


# pretty print an object's methods to console, with color
class Object

  ANSI_BOLD       = "\033[1m"
  ANSI_RESET      = "\033[0m"
  ANSI_LGRAY    = "\033[0;37m"
  ANSI_GRAY     = "\033[1;30m"

  # Print object's methods
  def pm(*options)
    methods = self.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = self.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name, args, klass]
    end
    max_name = data.collect {|item| item[0].to_s.size}.max
    max_args = data.collect {|item| item[1].to_s.size}.max
    data.each do |item|
      print " #{ANSI_BOLD}#{item[0].to_s.rjust(max_name)}#{ANSI_RESET}"
      print "#{ANSI_GRAY}#{item[1].to_s.ljust(max_args)}#{ANSI_RESET}"
      print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
    end
    data.size
  end

  def number_with_delimiter(number, delimiter=",")
    number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
  end

  class << self
    def number_with_delimiter(number, delimiter=",")
      number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    end
  end
end

