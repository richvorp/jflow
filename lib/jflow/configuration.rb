module JFlow
  class Configuration

    attr_accessor :swf_client, :load_paths, :logger, :activity_map, :cloudwatch_client, :error_handlers

    def initialize
      @swf_client        = nil
      @cloudwatch_client = nil
      @load_paths        = []
      @logger            = Logger.new(STDOUT)
      @activity_map      = JFlow::Activity::Map.new
      @error_handlers    = []
    end
  end
end