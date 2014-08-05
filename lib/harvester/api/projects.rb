module Harvester
  module API
    class Projects < Base

      def all
        make_projects(@harvest.projects.all)
      end

      # Returns only matching project
      def by_name(project_name)
        projects =  @harvest.projects.all.select{ |p| p.name.downcase.include?(project_name.downcase) }

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
