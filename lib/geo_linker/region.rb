require 'geo_linker/fias/tables'

module GeoLinker
  class Region
    include ActiveModel::Model
    attr_accessor :id, :name

    def initialize(addrobj)
      self.id = addrobj.regioncode
      self.name = addrobj.normal_name
    end

    def self.all
      Fias::Tables::Addrobj.regions.map do |f|
        self.new(f)
      end
    end

    def self.find(region_id)
      region = Fias::Tables::Addrobj.regions.where(regioncode: region_id.to_s.rjust(2, '0')).first
      self.new(region) if region
    end

    def to_h
      { id => name }
    end
  end
end
