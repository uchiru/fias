module GeoLinker::FIAS::Tables
  class Addrobj < ActiveRecord::Base
    self.table_name = 'fias_addrobjs'
    self.primary_key = 'aoid'

    default_scope { where livestatus: "1" }

    CITIES_LEVEL = %w(4 6)
    REGIONS_LEVEL = %w(1)

    has_many :childrens, class_name: "Addrobj",
      foreign_key: 'parentguid',
      primary_key: 'aoguid'
    has_one :next_active, class_name: "Addrobj",
      foreign_key: 'previd'

    belongs_to :ancestor, class_name: "Addrobj",
      primary_key: 'aoguid',
      foreign_key: 'parentguid'

    has_many :schools,
      foreign_key: 'addrobj_aoguid',
      primary_key: 'aoguid'

    scope :regions, -> { where(aolevel: "1") }
    scope :cities, -> (region_code, query, with_regions = nil) {
      level_filter = with_regions ? CITIES_LEVEL + REGIONS_LEVEL : CITIES_LEVEL
      where(regioncode: region_code, aolevel: level_filter).
        where("formalname ILIKE ? OR (shortname || ' ' || formalname) ILIKE ? ", "#{query}%", "#{query}%")
    }

    def self.cities_with_schools_in_region (region)
      fias_cities = connection.execute("
     SELECT distinct fias_addrobjs.offname FROM schools INNER JOIN fias_addrobjs ON schools.fias_addrobj_aoguid = fias_addrobjs.aoguid WHERE schools.region = #{region}
                                       ")
      custom_cities = connection.execute("
     SELECT distinct schools.custom_city FROM schools WHERE schools.region = #{region} AND schools.fias_addrobj_aoguid IS NULL
                                         ")
      (fias_cities.to_a + custom_cities.to_a).map{|i| i.values.first }
    end

    def normal_name
      case self.shortname.strip
      when "Чувашия"
        self.shortname.strip
      when "Респ"
        I18n.t "fias_addrobj.republic", name: self.offname
      when "обл"
        I18n.t "fias_addrobj.region", name: self.offname
      when "АО"
        self.offname.in?("Югра") ? self.offname : I18n.t("fias_addrobj.ao", name: self.offname)
      when "Аобл"
        I18n.t "fias_addrobj.aobl", name: self.offname
      when "край"
        I18n.t "fias_addrobj.edge", name: self.offname
      else
        self.offname
      end
    end

    def normal_city_name
      shortname + ' ' + formalname
    end

    def context_name
      case aolevel
      when '1' # субъект
        normal_name
      when '3' # район
        "#{offname} район"
      when '4' # город
        normal_city_name
      when '5' # хрен знает что такое
        normal_city_name
      when '6' # деревни, села, поселки и т.п.
        normal_city_name
      else
        normal_city_name
      end
    end

  end
end
