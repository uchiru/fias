require 'geo_linker/fias/tables'

module GeoLinker
  class City
    include ActiveModel::Model
    attr_accessor :id, :name

    def initialize(addrobj)
      self.id = addrobj.aoguid
      self.name = addrobj.normal_city_name
    end

    def self.all
      Fias::Tables::Addrobj.cities.map do |f|
        self.new(f)
      end
    end

    def self.find(city_id)
      city = Fias::Tables::Addrobj.cities.where(aoguid: city_id).first
      self.new(city) if city
    end

    def to_h
      { id => name }
    end
  end
end
