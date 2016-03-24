module JFlow
  class Domain

    attr_reader :domain_name

    def initialize(domain_name)
      @domain_name = domain_name
      create unless exists?
    end

    def create
      JFlow.configuration.logger.debug "Registering domain #{domain_name}"
      JFlow.configuration.swf_client.register_domain({
        name: domain_name,
        description: domain_name,
        workflow_execution_retention_period_in_days: "90"
      })
    end

    def exists?
      domains = JFlow.configuration.swf_client.list_domains({
        registration_status: "REGISTERED"
      })
      exists = domains.domain_infos
                      .map{|a| a.name}
                      .include?(domain_name)
      JFlow.configuration.logger.debug "#{domain_name} found: #{exists}"
      exists
    end

  end
end