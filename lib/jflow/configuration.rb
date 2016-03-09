module JFlow
  class Configuration

    attr_accessor :swf_client, :load_paths, :logger

    def initialize
      @swf_client = Aws::SWF::Client.new
      @load_paths = []
      @logger     = Logger.new(STDOUT)
    end
  end
end