require 'rails/generators/migration'

module Apicasso
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc 'Add the required migrations to run APIcasso'

      def self.next_migration_number(path)
        if @prev_migration_nr
          @prev_migration_nr += 1
        else
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        migration_template 'create_something.rb',
                           'db/migrate/create_apicasso_tables.rb'
      end
    end
  end
end