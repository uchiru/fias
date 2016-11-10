module GeoLinker::FIAS::Parser::ModelUpdater
  class ModelUpdater < ModelWriter
    def initialize(model)
      super(model)
      @updated_count = 0
    end

    def formated_changes(changes)
      changes.map {|x,y| "\t#{x}: #{y[0]} => #{y[1]}\n" }
    end

    def end_parse
      make_last_in_query!
      @logger.info("Updated: #{@updated_count}, created: #{@created_count}, failed: #{@failed_count}")
    end
  end
end
