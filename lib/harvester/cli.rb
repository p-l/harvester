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
    class_option :from, :desc => "From date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string
    class_option :to, :desc => "To date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string


    #---------------------------------------------------------------------------
    # find
    #---------------------------------------------------------------------------
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

    #---------------------------------------------------------------------------
    # summarize
    #---------------------------------------------------------------------------
    desc "summarize PROJECT", "Summarize tasks in PROJECT"
    option :name, :desc => "Specify a name", :yeal => :string
    def summarize(name)
      from_date = date_from_formated_string(options[:from])
      to_date = date_from_formated_string(options[:to])
      client = Client.new(options[:domain],options[:username],options[:password])
      puts "Searching for project named: #{name}."
      projects = client.projects.by_name(name)
      projects.sort_by().each do |p|
        puts " "
        puts "--------------------------------------------------------------------------"
        puts "#{p.name} (#{p.client.name})"
        puts "from: #{options[:from]}" if(options[:from])
        puts "to: #{options[:to]}" if(options[:to])
        puts "--------------------------------------------------------------------------"

        tasks = p.summary(from_date,to_date)

        # Generate summary
        total = 0
        unit = "hours"
        divider = 1
        if(options[:days])
          unit = "days"
          divider = (options[:day_length] ? options[:day_length] : 8)
        end

        # Enrich tasks (with name).
        named_tasks = {}
        tasks.each do |task_id, hours|
          task = client.tasks.by_id(task_id)
          named_tasks[task.name] = hours
          total += (hours/divider)
        end

        # Output tasks
        named_tasks.sort_by{|k,v| k}.each do |task_name, hours|
          puts "#{task_name} : #{(hours/divider).round(2)} #{unit}"
        end


        puts "Total : #{total.round(2)} #{unit}"
      end
    end # summarize

    #---------------------------------------------------------------------------
    # Utilities
    #---------------------------------------------------------------------------
    no_commands do
      def date_from_formated_string(date_string=nil)
        return nil if date_string == nil
        Date.strptime(date_string,"%Y-%m-%d")
      rescue Exception => e
        puts e.message
        puts "Date was: #{date_string}"
      end
    end # no_commands

  end # CLI
end # Harvester
