module JFlow
  class WorkerThread < Thread

    def mark_for_shutdown
      self["marked_for_shutdown"] = true
    end

    def marked_for_shutdown?
      self["marked_for_shutdown"] == true
    end

    def currently_working?
      self["state"] == :working
    end

    def currently_polling?
      self["state"] == :polling
    end

    def set_state(state)
      self["state"] = state
    end

  end
end