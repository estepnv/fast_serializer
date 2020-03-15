[![Gem Version](https://badge.fury.io/rb/fast_serializer_ruby.svg)](https://badge.fury.io/rb/fast_serializer_ruby)
[![Build Status](https://travis-ci.org/estepnv/fast_serializer.svg?branch=master)](https://travis-ci.org/estepnv/fast_serializer)
[![Maintainability](https://api.codeclimate.com/v1/badges/df7897bec85d376709bd/maintainability)](https://codeclimate.com/github/estepnv/fast_serializer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/df7897bec85d376709bd/test_coverage)](https://codeclimate.com/github/estepnv/fast_serializer/test_coverage)

# fast_serializer

`fast_serializer_ruby` is a lightweight ruby object to hash transformer.
This library intends to solve such a typical and on the other hand important problem as efficient ruby object to hash transformation.

## Performance 🚀
- running on ruby 2.6 is **at least 5 times faster** than AMS (benchmarks was borrowed from fast_jsonapi repository)
- running on ruby 2.6 it consumes **6 times less RAM**
- running on jruby 9.2.7.0 **is at least 15 times faster** than AMS after warming up

## Compatibility 👌
I tried to keep the API as close as possible to active_model_serializer implementation because we all got used to it.

## Features
- conditional rendering
- inheritence
- included/excluded associations


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_serializer_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_serializer_ruby

## Usage

`fast_serializer` supports default schema definition using class methods

```ruby
class ResourceSerializer
  include FastSerializer::Schema::Mixin

  root :resource

  attributes :id, :email, :phone

  attribute(:string_id, if: -> { params[:stringify] }) { resource.id.to_s }
  attribute(:float_id, unless: :stringify?) { object.id.to_f }
  attribute(:full_name) { params[:only_first_name] ? resource.first_name : "#{resource.first_name} #{resource.last_name}" }

  has_one :has_one_relationship, serializer: ResourceSerializer
  has_many :has_many_relationship, serializer: ResourceSerializer

  def stringify?
    params[:stringify]
  end
end

ResourceSerializer.new(resource, meta: {foo: "bar"}, only_first_name: false, stringify: true, exclude: [:has_many_relationship]).serializable_hash
=> {
     :resource => {
       :id => 7873392581,
       :email => "houston@luettgen.info",
       :full_name => "Jamar Graham",
       :phone => "627.051.6039 x1475",
       :has_one_relationship => {
         :id => 6218322696,
         :email=>"terrellrobel@pagac.info",
         :full_name => "Clay Kuphal",
         :phone => "1-604-682-0732 x882"
       }
     },
     meta: { foo: "bar" }
   }


```

Also fast_serializer supports runtime schema definition

```ruby
schema = FastSerializer::Schema.new(resource)
schema.attribute(:id)
schema.attribute(:email)
schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}"}
schema.attribute(:phone)
schema.has_one(:has_one_relationship, schema: schema)

schema.serializable_hash
=> {
     :id => 7873392581,
     :email => "houston@luettgen.info",
     :full_name => "Jamar Graham",
     :phone => "627.051.6039 x1475",
     :has_one_relationship => {
       :id => 6218322696,
       :email=>"terrellrobel@pagac.info",
       :full_name => "Clay Kuphal",
       :phone => "1-604-682-0732 x882"
     }
   }



```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/estepnv/fast_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastSerializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fast_serializer/blob/master/CODE_OF_CONDUCT.md).
