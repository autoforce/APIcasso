# frozen_string_literal: true

require 'cancancan'
require 'swagger/blocks'
require 'ransack'
require 'will_paginate/array'
require 'will_paginate'
require 'apicasso/version'
require 'apicasso/engine'
require 'apicasso/active_record_extension'
require 'friendly_id'

require 'apicasso/configuration'

# Load settings defined in initializer
module Apicasso
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
