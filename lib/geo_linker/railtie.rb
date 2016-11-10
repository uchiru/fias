module GeoLinker
  class Railtie < Rails::Railtie
    rake_tasks do
      load "#{GeoLinker::GEM_PATH}/lib/tasks/geo_linker.rake"
    end
  end
end
