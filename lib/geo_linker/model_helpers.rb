module GeoLinker::ModelHelpers
  def has_region(field, options={})
    define_method :region_model do
      GeoLinker::Region.find(self.send(field))
    end
  end

  def has_city(field, options={})
    define_method :city_model do
      GeoLinker::City.find(self.send(field))
    end
  end
end
