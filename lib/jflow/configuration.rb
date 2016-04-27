module JFlow
  class Configuration

    attr_accessor :swf_client, :load_paths, :logger, :activity_map, :cloudwatch_client

    def initialize
      @swf_client        = nil
      @cloudwatch_client = nil
      @load_paths        = []
      @logger            = Logger.new(STDOUT)
      @activity_map      = JFlow::Activity::Map.new
    end
  end
end