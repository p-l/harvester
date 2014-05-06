module Harvester
  module Models
    class Task
      attr_reader :id, :name, :billable, :deactivated

      def initialize(task_obj,client)
        @harvest = client
        @obj = task_obj
        @id = task_obj.id
        @name = task_obj.name
        @billabale = task_obj.billable?
        @deactivated = task_obj.deactivated?
      end

      def billable?
        @billable
      end

      def deactivated?
        @deactivated
      end

    end # Task
  end # Models
end # Harvester
