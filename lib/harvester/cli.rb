require "thor"
require "harvester/client"

module Harvester
  class CLI < Thor
    class_option :verbose, :aliases => "-v", :desc => "Verbose", :type => :boolean
    class_option :domain, :aliases => "-d", :desc => "Harvest domain", :type => :string
    class_option :username, :aliases => "-u", :desc => "Harvest username", :type => :string
    class_option :password, :aliases => "-p", :desc => "Harvest password", :type => :string


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
    option :day_length, :desc => "Length of a day", :type => :numeric
    option :days, :desc => "Use days as units", :type => :boolean
    option :from, :desc => "From date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string
    option :to, :desc => "To date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string
    def summarize(name)
      from_date = date_from_formated_string(options[:from])
      to_date = date_from_formated_string(options[:to])
      client = Client.new(options[:domain],options[:username],options[:password])
      puts "Searching for project named: '#{name}' ..."
      harvested_projects = client.projects.by_name(name)

      project_summaries = {}

      harvested_projects.each do |p|
        project_summaries[p] = p.summary(from_date,to_date)
      end

      # Generate summary
      unit = "hours"
      divider = 1
      if(options[:days])
        unit = "days"
        divider = (options[:day_length] ? options[:day_length] : 8)
      end

      if (options[:csv])
        puts "Not implemented yet :("
        #summary_as_csv(project_summaries,from_date,to_date,unit,divider)
      else
        summary_as_text(project_summaries,from_date,to_date,unit,divider)
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

      def summary_as_text(project_summaries,from=nil,to=nil,unit="hours",divider=1)
        project_summaries.sort_by().each do |p,tasks|
          puts " "
          puts "--------------------------------------------------------------------------"
          puts "#{p.name} (#{p.client.name})"
          puts "from: #{options[:from]}" if(options[:from])
          puts "to: #{options[:to]}" if(options[:to])
          puts "--------------------------------------------------------------------------"

          # Output as human readable text
          total = 0
          tasks.each do |task_name, hours|
            puts "#{task_name} : #{(hours/divider).round(2)} #{unit}"
            total += (hours/divider)
          end

          puts "Total : #{total.round(2)} #{unit}"
        end
      end

    end # no_commands
  end # CLI
end # Harvester
