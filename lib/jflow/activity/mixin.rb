module JFlow
  module Activity
    module Mixin

      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def activity(name = nil)
          options = {}
          options = yield if block_given?
          options[:name] = name
          JFlow.configuration.logger.debug "loading #{name}"
          JFlow::Activity::Definition.new(self, options)
        end
      end
    end
  end
end
