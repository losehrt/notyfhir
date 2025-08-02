# frozen_string_literal: true

require_relative "notyfhir/version"
require_relative "notyfhir/engine"
require_relative "notyfhir/configuration"

module Notyfhir
  class Error < StandardError; end
  
  class << self
    attr_accessor :configuration
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
  
  def self.reset_configuration!
    self.configuration = Configuration.new
  end
end
