require 'net/http'
require 'json'

module JFlow
  class TerminationProtector

    def region
      instance_data['region']
    end

    def instance_id
      instance_data['instanceId']
    end

    # Returns a hash of instance data, including region, instance id + more
    def instance_data
      @instance_data ||= JSON.parse(Net::HTTP.get(URI.parse('http://169.254.169.254/latest/dynamic/instance-identity/document')))
    end

    def get_asg_name
      ec2_client = Aws::EC2::Client.new(region: region)
      instance_tags = ec2_client.describe_tags(filters: [
        {
          name: "resource-id",
          values: [instance_id]
        }
      ])[0]
      asg_name = instance_tags.select{|tag| tag.key == "aws:autoscaling:groupName"}.first.value
      JFlow.configuration.logger.debug "Discovered autoscaling group name #{asg_name}"

      asg_name
    end

    def set_protection(protect_status)
      JFlow.configuration.logger.debug "Setting termination protection status to #{protect_status} for instance #{@instance_id} in region #{@region}"
      begin
        asg_client = Aws::AutoScaling::Client.new(region: region)
        asg_client.set_instance_protection({
          instance_ids: [instance_id],
          auto_scaling_group_name: get_asg_name,
          protected_from_scale_in: protect_status
        })
      rescue => e
        JFlow.configuration.logger.debug "Something went wrong setting termination proection: #{e.inspect}"
      end
    end

  end
end
