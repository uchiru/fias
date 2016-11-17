require 'activerecord-import/base'

module Fias::Parser
  class ModelWriter
    attr_reader :model, :current_attributes

    QUEUE_LENGTH_FOR_FORK = 40000
    QUEUE_PARTS = 4

    QUEUE_COUNT_IN_PART = QUEUE_LENGTH_FOR_FORK / QUEUE_PARTS

    def initialize
      @model = Fias::Region
      @logger = Logger.new("#{Rails.root}/log/#{model}_Update_#{Time.now.to_i}.log")
      @start_time = Time.now

      if GC.respond_to?(:copy_on_write_friendly=)
        GC.copy_on_write_friendly = true
      end
      @current_primary_key = 'guid'

      @created_count = 0
      @failed_count = 0
      @updated_count = 0
      @main_queue = []
    end

    def fork_and_iterate(queue, &block)
      queue_parts = queue.each_slice(QUEUE_COUNT_IN_PART).to_a
      QUEUE_PARTS.times do |part_number|
        Process.fork do
          ActiveRecord::Base.connection.disconnect!
          config = Rails.application.config.database_configuration[Rails.env]
          ActiveRecord::Base.establish_connection(config)
          queue_part = queue_parts[part_number]

          exit if (queue_part).nil?
          queue_part.group_by { |q| q[:models_level]}.each do |group, arr|
            if group.in? [:both, :region]
              Fias::Region.transaction do
                @model = Fias::Region
                regions = arr.map do |obj|
                  yield(obj.clone)
                end.compact
                Fias::Region.import regions, validate: false
              end
              if group == :both
                Fias::City.transaction do
                  @model = Fias::City
                  cities = arr.map do |obj|
                    yield(obj.clone)
                  end.compact
                  Fias::City.import cities, validate: false
                end
              end
            else
              Fias::City.transaction do
                @model = Fias::City
                cities = arr.map do |obj|
                  yield(obj.clone)
                end.compact
                Fias::City.import cities, validate: false
              end
            end
          end
          exit
        end
      end
      Process.waitall
    end

    def fork_and_write
      fork_and_iterate(@main_queue) do |attributes|
        next if attributes['level'].to_i > 6 || attributes['live_status'].to_i == 0
        create_or_update_object(attributes.clone)
      end

      @main_queue = []
    end

    def create_or_update_object(attributes)
      if @model == Fias::Region
        if attributes[:models_level] == :both
          attributes[:is_city] = true
        elsif attributes[:models_level] == :region
          attributes[:is_city] = false
        end
      end
      attributes.delete(:models_level)
      search_hash = { @current_primary_key => attributes[@current_primary_key] }
      model_object = (@model.unscoped.find_by(search_hash) || @model.new(attributes))

      if model_object.persisted?
        model_object.attributes = attributes
      end
      model_object
    rescue Exception => e
      @logger.error( <<-ERROR_DESC.strip_heredoc
        Failed in #{@model},
         #{@current_primary_key}: #{attributes[@current_primary_key]},
         attributes: #{attributes.inspect}
         error: #{e.message}
       ERROR_DESC
       )
      @failed_count += 1
      nil
    end

    def formated_changes(changes)
      changes.map {|x,y| "\t#{x}: #{y[0]} => #{y[1]}\n" }
    end

    def create_attributes(attrs)
      attrs_h = attrs.to_h
      @current_attributes = {}
      rules = {
        aoid: :aoid,
        aoguid: :guid,
        formalname: :formal_name,
        shortname: :short_name,
        regioncode: :region_code,
        offname: :official_name,
        aolevel: :level,
        livestatus: :live_status
      }
      rules.each do |fias_attr, model_attr|
        @current_attributes[model_attr.to_s] = attrs_h[fias_attr.to_s.upcase]
      end
      if @current_attributes["level"] == "1" && @current_attributes["short_name"] == "г"
        @current_attributes[:models_level] = :both
      elsif @current_attributes["level"] == "1" && @current_attributes["short_name"] != "г"
        @current_attributes[:models_level] = :region
      else
        @current_attributes[:models_level] = :city
      end
    rescue PG::Error => e
      @logger.error(e.message)
      ActiveRecord::Base.connection.disconnect!
      config = Rails.application.config.database_configuration[Rails.env]
      ActiveRecord::Base.establish_connection(config)
    end

    def write_attributes
      if @main_queue.length < QUEUE_LENGTH_FOR_FORK
        if @current_attributes
          @main_queue.push(@current_attributes)
          @current_attributes = nil
        end
      else
        fork_and_write
      end
    end

    def make_last_in_query!
      fork_and_write if @main_queue.length > 0
    end

    def end_parse
      make_last_in_query!
      @logger.info("Finished, created: #{@created_count}, failed: #{@failed_count}")
    end
  end
end
