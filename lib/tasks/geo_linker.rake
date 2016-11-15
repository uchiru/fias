require 'geo_linker'

namespace :geo_linker do
  desc 'Download last actual FIAS database from official website'
  task :download, [:dir] => :environment do |task, args|
    include GeoLinker::Fias::Parser::Tools

    puts download(args[:dir])
  end

  desc 'Import FIAS into database and download if needed'
  task :import, [:file] => :environment do |task, args|
    include GeoLinker::Fias::Parser::Tools

    if (file = args[:file]).blank?
      puts 'File is not specified, searching in the Internet'
      file = download()
    end
    import(extract(file))

    ActiveRecord::Base.connection.disconnect!
    config = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
    # Парсер валится с ошибкой подключения к PostgreSQL
    # 24..26 строчки кода, призваны решить эту проблему
  end

  # desc 'Retrieve last actual xml from official site and parse addrobjs and houses into db'
  # task :import, [:path] => :environment do |task, args|
  #   include GeoLinker::Fias::Parser::Tools

  #   selectors_hash = {fias_addrobj: /AS_ADDROBJ_/}
  #   if args[:dir].blank?
  #     p "Downloading last actual fias xml file from nalog.ru"
  #     xml_url = retrive_xml_link(type: :import)

  #     download_and_extract(xml_url, selectors_hash) do |parameters|
  #       handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
  #     end
  #   else
  #     p "Parsing files from #{args[:dir]}"
  #     take_from_directory(args[:dir], selectors_hash) do |parameters|
  #       handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelWriter)
  #     end
  #   end

  #   ActiveRecord::Base.connection.disconnect!
  #   config = Rails.application.config.database_configuration[Rails.env]
  #   ActiveRecord::Base.establish_connection(config)
  #   # Парсер валится с ошибкой подключения к PostgreSQL
  #   # 24..26 строчки кода, призваны решить эту проблему
  # end

  # desc 'Retrieve delta xml from site, extract and update databases'
  # task :update, [:dir] => :environment do |task, args|
  #   include GeoLinker::Fias::Parser::Tools

  #   selectors_hash = {fias_addrobj: /AS_ADDROBJ_/}
  #   if args[:dir].blank?
  #     p "Downloading last update from nalog.ru"
  #     xml_url = retrive_xml_link(type: :update)
  #     download_and_extract(xml_url,selectors_hash) do |parameters|
  #       handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
  #     end
  #   else
  #     p "Updating models from directory: #{args[:dir]}"
  #     take_from_directory(args[:dir], selectors_hash) do |parameters|
  #       handle_model_parsing(parameters, GeoLinker::Fias::Parser::ModelUpdater)
  #     end
  #   end

  #   ActiveRecord::Base.connection.disconnect!
  #   config = Rails.application.config.database_configuration[Rails.env]
  #   ActiveRecord::Base.establish_connection(config)
  #   # Парсер валится с ошибкой подключения к PostgreSQL
  #   # 49..51 строчки кода, призваны решить эту проблему
  # end
end
