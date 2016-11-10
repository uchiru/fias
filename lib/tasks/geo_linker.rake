require 'geo_linker'

namespace :geo_linker do
  namespace :parser do
    desc 'Retrieve last actual xml from official site and parse addrobjs and houses into db'
    task :import, [:dir] => :environment do |task, args|
      extend GeoLinker::Fias::Parser::Tools
      selectors_hash = {fias_addrobj: /AS_ADDROBJ_/}
      if args[:dir].blank?
        p "Downloading last actual fias xml file from nalog.ru"
        xml_url = retrive_xml_link(type: :import)

        download_and_extract(xml_url, selectors_hash) do |parameters|
          handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
        end
      else
        p "Parsing files from #{args[:dir]}"
        take_from_directory(args[:dir], selectors_hash) do |parameters|
          handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelWriter)
        end
      end

      ActiveRecord::Base.connection.disconnect!
      config = Rails.application.config.database_configuration[Rails.env]
      ActiveRecord::Base.establish_connection(config)
      # Парсер валится с ошибкой подключения к PostgreSQL
      # 24..26 строчки кода, призваны решить эту проблему
      FiasAddrobj.unscoped.delete_all(livestatus: "0")
    end

    desc 'Retrieve delta xml from site, extract and update databases'
    task :update, [:dir] => :environment do |task, args|
      extend GeoLinker::Fias::Parser::Tools
      selectors_hash = {fias_addrobj: /AS_ADDROBJ_/}
      if args[:dir].blank?
        p "Downloading last update from nalog.ru"
        xml_url = retrive_xml_link(type: :update)
        download_and_extract(xml_url,selectors_hash) do |parameters|
          handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
        end
      else
        p "Updating models from directory: #{args[:dir]}"
        take_from_directory(args[:dir], selectors_hash) do |parameters|
          handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
        end
      end

      ActiveRecord::Base.connection.disconnect!
      config = Rails.application.config.database_configuration[Rails.env]
      ActiveRecord::Base.establish_connection(config)
      # Парсер валится с ошибкой подключения к PostgreSQL
      # 49..51 строчки кода, призваны решить эту проблему
      FiasAddrobj.unscoped.delete_all(livestatus: "0")
    end
  end
end
