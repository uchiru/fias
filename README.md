# Fias

It helps your to add FIAS to any project

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fias', git: 'git@github.com:uchiru/fias.git'
```

And then execute:

    $ bundle

## Scripts

```shell
rails generate fias:install # Сгенерировать миграции
rake db:migrate # Мигрировать
rake fias:download # Скачать ФИАС архивом
rake fias:download[.] # Скачать ФИАС архивом в указанную папку
rake fias:import # Импортировать ФИАС себе в базу
rake fias:update # Пока не работает
```
## Usage

TODO: Write usage instructions here

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

