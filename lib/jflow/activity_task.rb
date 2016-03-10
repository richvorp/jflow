module JFlow
  class ActivityTask

    attr_reader :task

    def initialize(task)
      @task = task
    end

    def klass
      ret = $activity_map[name][version][:class]
      raise "Could not find code to run for given activity" unless ret
      ret
    end

    def name
      task.name
    end

    def version
      task.version
    end

    def method
      if name.split('.').size > 1
        method = name.split('.').last
      else
        method = "process"
      end
    end

    def run!(input)
      log "Started #{klass}##{method} with #{input}"
      result = klass.new.send(method, input) || "done"
      log "Result is #{result.class} #{result}"
    end

    def log(str)
      JFlow.configuration.logger.info "[#{Thread.current.object_id}] #{str}"
    end

  end
end