module JFlow
  module ActivityMixin

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def activity(name = nil)
        options = {}
        options = yield if block_given?
        options[:name] = name
        JFlow.configuration.logger.debug "loading #{name}"
        JFlow::Activity.new(self, options)
      end
    end
  end
end
