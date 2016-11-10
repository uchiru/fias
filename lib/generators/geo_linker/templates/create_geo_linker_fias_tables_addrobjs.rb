class GeoLinkerFiasTablesAddrobjs < ActiveRecord::Migration
  def change
    create_table :geo_linker_fias_tables_addrobjs, id: false do |f|
      f.string :aoid, primary: true
      f.string :aoguid
      f.string :formalname
      f.string :regioncode
      f.string :autocode
      f.string :areacode
      f.string :citycode
      f.string :ctarcode
      f.string :placecode
      f.string :streetcode
      f.string :extrcode
      f.string :sextcode
      f.string :offname
      f.string :postalcode
      f.string :ifnsfl
      f.string :terrifnsfl
      f.string :ifnsul
      f.string :terrifnsul
      f.string :okato
      f.string :oktmo
      f.string :shortname
      f.string :aolevel
      f.string :parentguid
      f.string :previd
      f.string :nextid
      f.string :code
      f.string :plaincode
      f.string :actstatus
      f.string :centstatus
      f.string :operstatus
      f.string :currstatus
      f.string :normdoc
      f.string :livestatus
      f.datetime :startdate
      f.datetime :enddate
      f.datetime :updatedate

      f.timestamps
    end
  end

end
