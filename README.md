[![Build Status](https://travis-ci.org/estepnv/fast_serializer.svg?branch=master)](https://travis-ci.org/estepnv/fast_serializer)
[![Maintainability](https://api.codeclimate.com/v1/badges/74cca93390234e619cf5/maintainability)](https://codeclimate.com/github/estepnv/fast_serializer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/74cca93390234e619cf5/test_coverage)](https://codeclimate.com/github/estepnv/fast_serializer/test_coverage)

# fast_serializer

fast_serializer is a lightweight ruby objects serializer. 

It has zero dependencies and written in pure ruby.
That's why it's so performant.

- running on ruby 2.6 is **at least 3 times faster** than AMS (benchmarks was borrowed from fast_jsonapi repository)
- running on jruby 9.2.7.0 **is at least 15 times faster** than AMS after warming up


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_serializer

## Usage

fast_serializer supports default schema definition using class methods

```ruby
class ResourceSerializer
  include FastSerializer::Schema::Mixin
  root :resource
  
  attributes :id, :email, :phone
  
  attribute(:string_id, if: -> (resource, params) { params[:stringify] }) { |resource, params| resource.id.to_s }
  attribute(:float_id, unless: -> (resource, params) { params[:stringify] }) { |resource, params| resource.id.to_f }
  attribute(:full_name) { |resource, params| params[:only_first_name] ? resource.first_name : "#{resource.first_name} #{resource.last_name}" }
  
  has_one :has_one_relationship, serializer: ResourceSerializer
  has_many :has_many_relationship, serializer: ResourceSerializer
end

ResourceSerializer.new(resource, meta: {foo: "bar"}, only_first_name: false, stringify: true).serializable_hash
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
schema.has_one(:has_one_relationship, serializer: schema)

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

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/estepnv/fast_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastSerializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fast_serializer/blob/master/CODE_OF_CONDUCT.md).
