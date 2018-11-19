require 'rails/generators/migration'

module Apicasso
  module Generators
    # Class used to install Apicasso engine into a project
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc 'Add the required migrations to run APIcasso'

      # Method generates the next migration number
      # @param path [String] the path to migration directory
      # @returns [String] the next migration number
      def self.next_migration_number(path)
        if @prev_migration_nr
          @prev_migration_nr += 1
        else
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        end
        @prev_migration_nr.to_s
      end

      # Create a migration to setup database tables used by the
      # engine to implement authentication, authorization and auditability
      def copy_migrations
        migration_template 'create_apicasso_tables.rb',
                           'db/migrate/create_apicasso_tables.rb'
      end
    end
  end
end
