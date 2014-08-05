module Harvester
  module API
    class Projects < Base

      def all
        make_projects(@harvest.projects.all)
      end

      def active
        projects =  @harvest.projects.all.select{ |p| p.active }
        make_projects(projects)
      end

      # Returns only matching project
      def by_name(project_name,options={})
        all_projects = not(options[:inactive]) ? self.active : self.all
        projects =  all_projects.select{ |p| p.name.downcase.include?(project_name.downcase).equal?(!options[:exclude]) }

        make_projects(projects)
      end

      def by_code(project_code,options={})
        all_projects = not(options[:inactive]) ? self.active : self.all
        projects =  all_projects.select{ |p| p.code.downcase.include?(project_code.downcase).equal?(!options[:exclude]) }

        make_projects(projects)
      end

      def by_id(project_id)
        project_obj = @harvest.projects.find(project_id)
        Models::Project.new(project_obj,@harvest)
      end

      def by_client_id(client_id)
        all_projects = @harvest.projects.all

        projects = all_projects.select{ |p| p.client_id == client_id }

        make_projects(projects)
      end

      def make_projects(harvest_projects)
        projects = []
        harvest_projects.each do |p|
          projects << Models::Project.new(p,@harvest)
        end
        return projects
      end
      private :make_projects

    end # Projects
  end # API
end # Harvester
