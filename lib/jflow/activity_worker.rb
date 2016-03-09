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

      klass = class_for_activity(response.activity_type)
      raise "Could not find code to run for given activity" unless klass

      begin
        JFlow.configuration.logger.debug "Started #{klass}#process with #{YAML.load(response.input)}"
        if response.activity_type.name.split('.').size > 1
          method = response.activity_type.name.split('.').last
        else
          method = "process"
        end
        result = klass.new.send(method, YAML.load(response.input)) || true
        JFlow.configuration.logger.debug "Done #{klass}##{method}"
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

    def class_for_activity(activity_type)
      $activity_map[activity_type.name][activity_type.version][:class]
    end

  end
end