module JFlow
  class Cli

    VALIDATION = {
      "number_of_workers" => "integer",
      "domain"            => "string",
      "tasklist"          => "string",
      "activities_path"   => "array"
    }

    attr_reader :number_of_workers, :domain, :tasklist, :worker_threads, :activities_path

    def initialize(options)
      validate_options(options)
      @number_of_workers  = options["number_of_workers"]
      @domain             = options["domain"]
      @tasklist           = options["tasklist"]
      @activities_path    = options["activities_path"]
      @worker_threads     = []
      setup
    end

    def start_workers
      number_of_workers.times do
        worker_threads << worker_thread
      end
      worker_threads.each(&:join)
    end

    # here we want to handle all cases for clean kill of the workers.
    # there is two state on which the workers can be
    # - Polling : they are not working on anything and are just waiting for a task
    # - Working : they are processing an activity right now
    #
    # for Polling, we cannot stop it in flight, so we send a signal to stop
    # polling after the current long poll finishes, IF it picks up anything in the mean time
    # the activity will be force failed
    #
    # for Working, we give a grace period of 60 seconds to finish otherwise we just send
    # an exception to the thread to force the failure.
    #
    # Shutting down workers will take a exactly 60 secs in all cases.
    def shutdown_workers
      log "Sending kill signal to running threads. Please wait for current polling to finish"
      kill_threads = []
      worker_threads.each do |thread|
        thread.mark_for_shutdown
        if thread.currently_working?
            kill_threads << kill_thread(thread)
        end
      end
      kill_threads.each(&:join)
    end

    private

    def setup
      JFlow.configure do |c|
        c.load_paths = activities_path
        c.swf_client = Aws::SWF::Client.new
      end
      JFlow.load_activities
    end

    def kill_thread(thread)
      Thread.new do
        sleep 60
        if thread.alive?
          thread.raise("Workers are going down!")
        end
      end
    end

    def log(str)
      JFlow.configuration.logger.info str
    end

    def worker_thread
      JFlow::WorkerThread.new do
        worker.start!
      end
    end

    def worker
      JFlow::Activity::Worker.new(domain, tasklist)
    end

    def validate_options(options)
      validator = HashValidator.validate(options, VALIDATION)
      raise "configuration is invalid! #{validator.errors}" unless validator.valid?
    end

  end
end