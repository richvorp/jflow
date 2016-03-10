require "jflow/version"
require "jflow/activity.rb"
require "jflow/activity_mixin.rb"
require "jflow/activity_task.rb"
require "jflow/activity_worker.rb"
require "jflow/configuration.rb"
require "yaml"
require "json"
require "hash_validator"
require 'aws-sdk'

module JFlow
  class << self
    attr_writer :configuration
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

  def self.load_activities
    configuration.load_paths.each do |path|
      Dir["#{path}/*.rb"].each do |file|
        configuration.logger.debug "found #{file}"
        require file
      end
    end
  end
end
