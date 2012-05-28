#require "charles/version"
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'htmlentities'

require 'ferret'
Ferret.locale = "en_US.UTF-8" #if not set ferret segfaults on chinese/jap stuff randomly

require "charles/document"
require "charles/misc"

module Charles
  # Your code goes here...
  def self.logger=(logger)
    @logger = logger
  end
  def self.logger
    @logger ||= Logger.new(STDERR)
  end
end

module Enumerable

  def sum
    return self.inject(0){|accum, i| accum + i }
  end

  def mean
    return self.sum / self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
    return sum / (self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end

end

