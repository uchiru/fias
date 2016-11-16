module Fias::Parser
  class ModelWriter
    attr_reader :model, :current_attributes

    QUEUE_LENGTH_FOR_FORK = 4000
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
                arr.each do |obj|
                  yield(obj)
                end
              end
              if group == :both
                Fias::City.transaction do
                  @model = Fias::City
                  arr.each do |obj|
                    yield(obj)
                  end
                end
              end
            else
              Fias::City.transaction do
                @model = Fias::City
                arr.each do |obj|
                  yield(obj)
                end
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
        next if attributes['aolevel'].to_i > 6
        create_or_update_object(attributes)
      end

      @main_queue = []
    end

    def create_or_update_object(attributes)
      if attributes[:models_level] == :both
        attributes[:is_city] = true
      elsif attributes[:models_level] == :region
        attributes[:is_city] = false
      end
      attributes.delete(:models_level)
      search_hash = { @current_primary_key => attributes[@current_primary_key] }
      model_object = (@model.unscoped.find_by(search_hash) || @model.new(attributes))

      if model_object.persisted?
        model_object.attributes = attributes
        changes = model_object.changes

        if model_object.save
          @updated_count += 1
          @logger.info("Updated #{model}, #{model_object.send(@current_primary_key)}, changes: #{formated_changes(changes).join}")
        else
          @failed_count += 1
          @logger.error("Failed to update #{model}, #{model_object.send(@current_primary_key)}, changes: #{formated_changes(changes).join}")
        end
      else
        model_object.save!
        @created_count += 1
        @logger.info("Created new #{model}: #{@current_primary_key}: #{attributes[@current_primary_key]}")
      end
    rescue Exception => e
      @logger.error( <<-ERROR_DESC.strip_heredoc
        Failed in #{@model},
         #{@current_primary_key}: #{attributes[@current_primary_key]},
         attributes: #{attributes.inspect}
         error: #{e.message}
       ERROR_DESC
       )
      @failed_count += 1
    end

    def formated_changes(changes)
      changes.map {|x,y| "\t#{x}: #{y[0]} => #{y[1]}\n" }
    end

    def create_attributes(attrs)
      attrs_h = attrs.to_h
      @current_attributes = {}
      rules = {
        aoid: :id,
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
      if attrs_h["AOLEVEL"] == "1" && attrs_h["SHORTNAME"] == "г"
        @current_attributes[:models_level] = :both
      elsif attrs_h["AOLEVEL"] == "1" && attrs_h["SHORTNAME"] != "г"
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
      if @main_queue.length < 2500
        @main_queue.push(@current_attributes)
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
