module Harvester
  module API
    class Tasks < Base
      def by_id(task_id)
        task_obj = @harvest.tasks.find(task_id)
        Models::Task.new(task_obj,@harvest)
      end

      def make_tasks(harvest_tasks)
        tasks = []
        harvest_tasks.each do |t|
          projects << Models::Task.new(t,@harvest)
        end
        return tasks
      end
      private :make_tasks

    end # Tasks
  end # API
end # Harvester
