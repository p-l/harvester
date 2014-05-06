require 'harvested'
require 'harvester/ssl'

module Harvester
  class Client
    def initialize(domain=nil,username=nil,password=nil)
      @domain = ENV['HARVEST_DOMAIN'] unless(domain)
      @username = ENV['HARVEST_USERNAME'] unless(username)
      @password = ENV['HARVEST_PASSWORD'] unless(password)
      @harvest = Harvest.client(@domain,@username,@password)
    rescue Harvest::InvalidCredentials => e
      raise InvalidCredentials.new("Invalid domain, username or password. Could not login to Harvest domain \"#{@domain}\" with username \"#{@username}\"")
    end

    def projects
      @projects ||= API::Projects.new(@harvest)
    end

    def tasks
      @tasks ||= API::Tasks.new(@harvest)
    end

    def clients
      @clients ||= API::Clients.new(@harvest)
    end

  end # Client
end # Harvester
