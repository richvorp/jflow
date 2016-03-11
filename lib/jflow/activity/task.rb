module JFlow
  module Activity
    class Task

      attr_reader :task

      def initialize(task)
        @task = task
      end

      def input
        YAML.load(task.input)
      end

      def name
        task.activity_type.name
      end

      def version
        task.activity_type.version
      end

      def token
        task.task_token
      end

      def klass
        @klass_value ||= JFlow.configuration.activity_map.klass_for(name,version)
        raise "Could not find code to run for given activity" unless @klass_value
        @klass_value
      end

      def method
        if name.split('.').size > 1
          method = name.split('.').last
        else
          method = "process"
        end
      end

      def run!
        log "Started #{klass}##{method} with #{input}"
        result = klass.new.send(method, *input) || "done"
        log "Result is #{result.class} #{result}"
        completed!(result)
      end

      def completed!(result)
        swf_client.respond_activity_task_completed({
          task_token: token,
          result: result,
        })
      end


      def failed!(exception)
        swf_client.respond_activity_task_failed({
          task_token: token,
          reason: exception.message,
          details: exception.backtrace.join("\n"),
        })
      end

      private

      def swf_client
        JFlow.configuration
             .swf_client
      end

      def log(str)
        JFlow.configuration.logger.info "[#{Thread.current.object_id}] #{str}"
      end
    end
  end
end