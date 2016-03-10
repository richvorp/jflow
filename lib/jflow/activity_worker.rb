module JFlow
  class ActivityWorker

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
      begin
        result = ActivityTask.new(response.activity_type).run!(YAML.load(response.input))
        JFlow.configuration.swf_client.respond_activity_task_completed({
          task_token: response.task_token,
          result: result,
        })
      rescue => e
        JFlow.configuration.swf_client.respond_activity_task_failed({
          task_token: response.task_token,
          reason: e.message,
          details: e.backtrace.join("\n"),
        })
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