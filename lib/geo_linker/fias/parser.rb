module GeoLinker::Fias
  module Parser
    require "geo_linker/fias/parser/model_writer"
    require "geo_linker/fias/parser/model_updater"
    require "geo_linker/fias/parser/tools"
  end

  class NokogiriParser < Nokogiri::XML::SAX::Document
    attr_reader :io, :progress, :logger, :handler, :obj_tag

    def initialize(io, handler, obj_tag)
      @obj_tag = obj_tag
      @handler = handler
      @io = io
      @progress = ProgressBar.new("Converting", io.size)
      @tags_count = 0
      @writed_count = 0
      start_parse()
      @progress.finish
    end

    def start_parse
      Nokogiri::XML::SAX::Parser.new(self).parse(@io)
    end

    def start_element(name, attrs = [])
      return unless name.to_s.eql?(@obj_tag)
      @handler.create_attributes(attrs)
    end

    def end_element(name)
      @handler.write_attributes
      @progress.set(@io.pos)
    end

    def end_document
      @handler.end_parse()
    end
  end
end
