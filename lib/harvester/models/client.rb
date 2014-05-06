module Harvester
  module Models
    class Client
      attr_reader :id, :name, :active

      def initialize(client_obj,client)
        @harvest = client
        @obj = client_obj

        @id = client_obj.id
        @name = client_obj.name
        @active = client_obj.active?
      end

      def billable?
        @billable
      end

      def active?
        @active
      end

      def projects
        @projects ||= API::Projects.new(@harvest).by_client_id(@id)
      end


    end # Client
  end # Models
end # Harvester
