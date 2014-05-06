require "thor"
require "harvester/client"

module Harvester
  class CLI < Thor
    class_option :verbose, :aliases => "-v", :desc => "Verbose", :type => :boolean
    class_option :domain, :aliases => "-d", :desc => "Harvest domain", :type => :string
    class_option :username, :aliases => "-u", :desc => "Harvest username", :type => :string
    class_option :password, :aliases => "-p", :desc => "Harvest password", :type => :string
    class_option :day_length, :desc => "Length of a day", :type => :numeric
    class_option :days, :desc => "Use days as units", :type => :boolean


    desc "find SEARCH_STRING", "Search Harvest for SEARCH_STRING"
    option :search_string, :description => "Specify a search string", :yeal => :string
    def find(name)
      client = Client.new(options[:domain],options[:username],options[:password])

      puts "Projects matching:\"#{name}\"."
      puts "--------------------------------------------------------------------------"
      projects = client.projects.by_name(name)
      projects.each { |p| puts "#{p.name} [id:#{p.id}]"}
      puts " "

      puts "Client matching:\"#{name}\"."
      puts "--------------------------------------------------------------------------"
      clients = client.clients.by_name(name)
      clients.each do |c|
        puts "#{c.name} [id:#{c.id}]"
        c.projects.each do |p|
          puts "  > #{p.name} [id:#{p.id}]"
        end
      end
    end # find


    desc "summarize PROJECT", "Summarize taks in PROJECT"
    option :name, :desc => "Specify a name", :yeal => :string
    def summarize(name)
      client = Client.new(options[:domain],options[:username],options[:password])
      puts "Searching for project named: #{name}."
      projects = client.projects.by_name(name)
      projects.each do |p|
        puts " "
        puts "--------------------------------------------------------------------------"
        puts "#{p.name} (#{p.client.name})"
        puts "--------------------------------------------------------------------------"

        tasks = p.summary()

        # Generate summary
        total = 0
        unit = "hours"
        divider = 1
        if(options[:days])
          unit = "days"
          divider = (options[:day_length] ? options[:day_length] : 8)
        end

        tasks.each do |task_id, hours|
          task = client.tasks.by_id(task_id)
          puts "#{task.name} : #{(hours/divider).round(2)} #{unit}"
          total += (hours/divider)
        end
        puts "Total : #{total.round(2)} #{unit}"
      end
    end # summarize

  end # CLI
end # Harvester
