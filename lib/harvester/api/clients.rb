module Harvester
  module API
    class Clients < Base

      def by_name(client_name)
        all_clients = @harvest.clients.all

        # Returns only matching project
        clients = all_clients.select{ |c| c.name.downcase.include?(client_name.downcase) }

        make_clients(clients)
      end

      def by_id(client_id)
        client_obj = @harvest.clients.find(client_id)
        Models::Client.new(client_obj,@harvest)
      end

      def make_clients(harvest_clients)
        clients = []
        harvest_clients.each do |p|
          clients << Models::Client.new(p,@harvest)
        end
        return clients
      end
      private :make_clients

    end # Clients
  end # API
end # Harvester
