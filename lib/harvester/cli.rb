require "thor"
require "harvester/client"
require 'csv'

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
    option :search, :desc => "Summarize only project matching string", :yeal => :string
    option :day_length, :desc => "Length of a day", :type => :numeric
    option :days, :desc => "Use days as units", :type => :boolean
    option :from, :desc => "From date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string
    option :to, :desc => "To date in format YYYY-MM-DD (e.g. 2014-01-31)", :yeal => :string
    option :csv, :desc => "Output summary in CSV format", :yeal => :boolean
    def summarize()
      from_date = date_from_formated_string(options[:from])
      to_date = date_from_formated_string(options[:to])
      client = Client.new(options[:domain],options[:username],options[:password])
      unless (options[:search])
        harvested_projects = client.projects.all
      else
        $stderr.puts "Searching projets for: \"#{options[:search]}\""
        harvested_projects = client.projects.by_name(options[:search])
      end

      project_summaries = {}

      $stderr.puts "Gathering project information... This may take a while."
      harvested_projects.each do |p|
        project_summaries[p] = p.summary(from_date,to_date)
      end

      # Setup report format
      unit = "hours"
      divider = 1
      if(options[:days])
        unit = "days"
        divider = (options[:day_length] ? options[:day_length] : 8)
      end

      if (options[:csv])
        summary_as_csv(project_summaries,from_date,to_date,unit,divider)
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
      end #date_from_formated_string

      def summary_as_text(project_summaries,from=nil,to=nil,unit="hours",divider=1)
        project_summaries.to_h.each do |p,tasks|
          puts " "
          puts "--------------------------------------------------------------------------"
          puts "#{p.name} (#{p.client.name})"
          puts "from: #{options[:from]}" if(options[:from])
          puts "to: #{options[:to]}" if(options[:to])
          puts "--------------------------------------------------------------------------"

          # Output as human readable text
          total = 0
          tasks.sort_by{|k,v| k.downcase}.each do |task_name, hours|
            puts "#{task_name} : #{(hours/divider).round(2)} #{unit}"
            total += (hours/divider)
          end # tasks.each

          puts "Total : #{total.round(2)} #{unit}"
        end # project_summaries.sort_by().each
      end # summary_as_text

      def summary_as_csv(project_summaries,from=nil,to=nil,unit="hours",divider=1)
        # Get the column lookup
        all_tasks_name = []
        project_summaries.each do |p,tasks|
          tasks.each do |task_name, hours|
            all_tasks_name << task_name
          end
        end # project_summaries.each

        task_columns = all_tasks_name.uniq.sort

        csv_content = CSV.generate do |csv|
          # Header
          header = [ "Project Name", "Client Name" ]
          task_columns.each { |task_name| header << task_name }
          header << "Total"
          csv << header

          # Create project row
          project_summaries.each do |p,project_tasks|
            total = 0
            project_row = []
            project_row << p.name
            project_row << p.client.name

            task_columns.each do |task_name,hours|
              # default to 0 if not in the hashmap
              task_value = project_tasks[task_name] ? (project_tasks[task_name]/divider).round(2) : 0
              project_row << task_value
              total += task_value
            end # task_columns.each

            project_row << total
            csv << project_row

          end # project_summaries.each
        end # CSV.generate

        puts csv_content
      end #summary_as_csv

    end # no_commands
  end # CLI
end # Harvester
