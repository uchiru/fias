module Fias
  class Railtie < Rails::Railtie
    rake_tasks do
      load "#{Fias::GEM_PATH}/lib/tasks/fias.rake"
    end
  end
end
