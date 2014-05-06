module Harvester
  module Model
    class Project
      attr_reader :id, :name, :client_id, :billable, :active

      def initialize(project_obj,client)
        @harvest = client
        @id = project.id
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

    end
  end
end
