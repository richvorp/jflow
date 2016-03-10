module JFlow
  class Configuration

    attr_accessor :swf_client, :load_paths, :logger, :activity_map

    def initialize
      @swf_client    = Aws::SWF::Client.new
      @load_paths    = []
      @logger        = Logger.new(STDOUT)
      @activity_map  = JFlow::Activity::Map.new
    end
  end
end