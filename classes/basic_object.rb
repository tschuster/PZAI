require 'rubygems'
require 'json'
require 'socket'
require 'logger'
require 'date'
class BasicObject
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class Array
  alias_method :blank?, :empty?
end

class Hash
  alias_method :blank?, :empty?

  def symbolize_keys
    dup.symbolize_keys!
  end

  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
end

class String
  def blank?
    self !~ /[^[:space:]]/
  end

  def squish
    dup.squish!
  end

  def squish!
    strip!
    gsub!(/\s+/, ' ')
    self
  end
end

class Numeric
  def blank?
    false
  end
end

class TCPSocket
  def open?
    present? && !closed?
  end
end