require 'fattr'

# convenience methods for Fattr's library
module FattrJSON
  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  def ancestors
    [self]
  end

  def self.ancestors
    [self]
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def fattrs
    self.class.fattrs
  end

  def to_hash
    fattrs.inject({}){|h,a| h.update a => send(a)}
  end

  def to_full_hash
    instance_variables.inject({}){|h,a| h.update "#{a.to_s.gsub('@','')}" => send("#{a.to_s.gsub('@','')}")}
  end

  def fattr_inspect
    to_hash.inspect
  end

  def fattr_pretty_inspect
    to_hash.pretty_print_inspect
  end

  def full_inspect
    to_full_hash.inspect
  end

  def full_pretty_inspect
    to_full_hash.pretty_print_inspect
  end

end