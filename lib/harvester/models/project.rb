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
        @code = project_obj.code
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

      def code
        @code
      end

      def summary(from=nil, to=nil, use_ids=false)
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

        # return task by id
        return summary_by_taskid if (use_ids)

        # go the extra mile and get task names for task ids
        summary_by_task_name = {}
        summary_by_taskid.each do |task_id, hours|
          task = API::Tasks.new(@harvest).by_id(task_id)
          summary_by_task_name[task.name] = hours
        end

        # return tasks by name
        return summary_by_task_name
      end

    end # Project
  end # Models
end # Harvester
