# GeoLinker

It helps your to add FIAS to any project

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geo_linker', git: 'git@github.com:uchiru/geo_linker.git'
```

And then execute:

    $ bundle

## Scripts

```shell
rails generate geo_linker:install # Сгенерировать миграции
rake db:migrate # Мигрировать
rake geo_linker:download # Скачать ФИАС архивом
rake geo_linker:download[.] # Скачать ФИАС архивом в указанную папку
rake geo_linker:import # Импортировать ФИАС себе в базу
rake geo_linker:update # Пока не работает
```
## Usage

TODO: Write usage instructions here

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

