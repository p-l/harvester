module Harvester
  module Models
    class Project
      attr_reader :id, :name, :client_id, :billable, :active

      def initialize(project_obj,client)
        @harvest = client
        @obj = project_obj
        @id = project_obj.id
        @name = project_obj.name
        @client_id = project_obj.client_id
        @billabale = project_obj.billable?
        @active = project_obj.active?
      end

      def billable?
        @billable
      end

      def active?
        @active
      end

      def client
        @client ||= API::Clients.new(@harvest).by_id(@client_id)
      end

      def summary(from=nil, to=nil)
        from ||= Time.utc(1970, 01, 01)
        to ||= Time.now.utc

        # Grab all time entries between from and to.
        all_entries = @harvest.reports.time_by_project(@id, from, to)

        # Add entries by task_id
        summary_by_taskid = {}
        all_entries.each do |e|
          summary_by_taskid[e.task_id] ||= 0
          summary_by_taskid[e.task_id] += e.hours
        end

        return summary_by_taskid
      end

    end # Project
  end # Models
end # Harvester
