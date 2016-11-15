require "rails/generators"
require "rails/generators/active_record"
module GeoLinker
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path("../templates", __FILE__)

    desc "This generator creates (but does not run) a migration to add a geo_linker_fias_addrobjs table"
    def create_migration_file
      add_geo_linker_migration("create_geo_linker_regions")
      add_geo_linker_migration("create_geo_linker_cities")
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    private

    def add_geo_linker_migration(template)
      migration_dir = File.expand_path("db/migrate")
      if self.class.migration_exists?(migration_dir, template)
        ::Kernel.warn "Migration already exists: #{template}"
      else
        migration_template "#{template}.rb", "db/migrate/#{template}.rb"
      end
    end
  end
end
