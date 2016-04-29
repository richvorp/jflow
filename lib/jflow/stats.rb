module JFlow
  class Stats

    attr_reader :domain_name, :tasklist

    def initialize(domain_name, tasklist)
      @domain_name = domain_name
      @tasklist    = tasklist
    end

    def tick
      value = backlog_count
      JFlow.configuration.cloudwatch_client.put_metric_data({
        namespace: "SWF/Custom",
        metric_data: [
          {
            metric_name: "TasklistBacklog",
            dimensions: [
              {
                name: "Domain",
                value: domain_name,
              },{
                name: "Tasklist",
                value: tasklist,
              }
            ],
            timestamp: Time.now,
            value: value,
            unit: "Count"
          },
        ],
      })
      JFlow.configuration.logger.debug "Sending tick stats with value: #{value}"
    end

    def backlog_count
      JFlow.configuration.swf_client.count_pending_activity_tasks({
        domain: domain_name,
        task_list: {
          name: tasklist,
        },
      }).count
    end

  end
end