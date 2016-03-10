module JFlow
  module Activity
    class Worker

      attr_reader :domain, :tasklist

      def initialize(domain, tasklist)
        @domain = domain
        @tasklist = tasklist
      end

      def start!
        loop do
          log "Polling for task on #{domain} - #{tasklist}"
          poll
        end
      end

      private

      def poll
        response = JFlow.configuration.swf_client.poll_for_activity_task(poll_params)
        if response.task_token
          process_task(response)
        else
          log "Got no task"
        end
      end

      def process_task(response)
        log "Got task #{response.task_token}"
        task = JFlow::Activity::Task.new(response)
        begin
          task.run!
        rescue => exception
          task.failed!(e)
        end
      end

      def identity
        @identity ||= "#{`hostname`.chomp}-#{Thread.current.object_id}"
      end

      def log(str)
        JFlow.configuration.logger.info "[#{Thread.current.object_id}] #{str}"
      end

      def poll_params
        {
          domain: domain,
          task_list: {
            name: tasklist,
          },
          identity: identity,
        }
      end

    end
  end
end