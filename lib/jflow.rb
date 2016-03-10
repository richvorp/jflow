require "yaml"
require "json"
require "hash_validator"
require 'aws-sdk'
require 'logger'
require "jflow/version"
require "jflow/configuration.rb"
require "jflow/activity/definition.rb"
require "jflow/activity/mixin.rb"
require "jflow/activity/task.rb"
require "jflow/activity/map.rb"
require "jflow/activity/worker.rb"

module JFlow
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.load_activities
    configuration.load_paths.each do |path|
      Dir["#{path}/*.rb"].each do |file|
        configuration.logger.debug "found #{file}"
        require file
      end
    end
  end
end
