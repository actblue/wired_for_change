require 'net/http'

module UriEncoder
  def escape(v)
    URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def uri_encode(params)
    if params.is_a?(Hash)
      params.map{|k,v| "#{k}=#{escape(v)}" }.join("&")
    elsif params.is_a?(Array)
      if params.size == 2 && (params.first.is_a?(String) || params.first.is_a?(Symbol)) && params.last.is_a?(String)
        "#{params.first}=#{escape(params.last)}"
      else
        params.map{|pair| uri_encode(pair)}.join("&")
      end
    elsif params.is_a?(SalsaObject)
      params.uri_encoded
    else
      raise RuntimeError, "I only know how to encode hashes and arrays, not #{params.class}"
    end
  end
end

class SalsaObject
  include UriEncoder
  class << self
    attr_accessor :salsa_attributes
  end
  def initialize(options={})
    options.each do |k,v|
      self.send((k.to_s+'=').to_sym, v)
    end
  end
  def self.salsa_attribute(*attr_names)
    self.salsa_attributes ||= []
    attr_names.each do |attr_name|
      self.salsa_attributes << attr_name
      attr_accessor attr_name
    end
  end
  def attributes_encoded
    self.class.salsa_attributes.map do |attr_name| 
      value = self.send(attr_name)
      if value.is_a?(Array)
        value.map{ |v| uri_encode([attr_name, v.to_s])}.join("&")
      elsif value.nil?
        nil
      else
        uri_encode([attr_name, value.to_s])
      end
    end.compact.join("&")
  end
  def uri_encoded
    "object=#{self.class.name[5..-1].downcase}&#{attributes_encoded}"
  end
end
