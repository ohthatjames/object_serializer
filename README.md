# ObjectSerializer

A proof-of-concept at moving serialization out of the objects they're serializing. Hasn't been used in anger yet.

## Installation

Add this line to your application's Gemfile:

    gem 'object_serializer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install object_serializer

## Usage

Imagine the following object model:

```ruby
Person = Struct.new(:first_name, :last_name, :company, :catchphrases)
Company = Struct.new(:name)
Catchphrase = Struct.new(:phrase)
fred = Person.new("Fred",
                  "Flintstone",
                  Company.new("Slate Rock and Gravel Company"),
                  [Catchphrase.new("Yabba Dabba Do!"), Catchphrase.new("WILMA!!!")])
```

You can create a simple name serializer with:

```ruby
serializer = ObjectSerializer::Serializer.new do |s|
  s.attribute :first_name
end

serializer.serialize(fred) # => { "first_name" => "Fred" }
```

You can add extra attributes:

```ruby
serializer.add_attribute :last_name

serializer.serialize(fred) # => { "first_name" => "Fred", "surname" => "Flintstone" }
```

You can extend serializers:

```ruby
full_name_serializer = serializer.compose do |s|
  s.attribute :last_name
end
full_name_serializer.serialize(fred).should == {"first_name" => "Fred", "last_name" => "Flintstone"}
```

You can add custom add custom attributes, or rename them:

```ruby
ObjectSerializer::Serializer.new do |s|
  s.attribute :given_name, :calling => :first_name
  s.attribute :capitalized_surname, :calling => lambda {|person| person.last_name.capitalize }
end

serializer.serialize(fred) # => { "given_name" => "Fred", "surname" => "FLINTSTONE" }
```

You can nest serializers to allow fine-grained control of attributes:

```ruby
company_serializer = ObjectSerializer::Serializer.new do |s|
  s.attribute :name
end
serializer = person_serializer.compose do |s|
  s.attribute :company, :serializer => company_serializer
end

serializer.serialize(fred) # => { "first_name" => "Fred", "company" => {"name" => "Slate Rock and Gravel Company"}}
```

You can serialize collections:

```ruby
catchphrase_serializer = ObjectSerializer::Serializer.new do |s|
  s.attribute :phrase
end
serializer = person_serializer.compose do |s|
  s.attribute :catchphrases, :collection => true, :serializer => catchphrase_serializer
end
serializer.serialize(fred)["catchphrases"] # => [{"phrase" => "Yabba Dabba Do!"}, { "phrase" => "WILMA!!!"}]
```

## License

See LICENSE.txt

## TODO

* See if it works in the real world!
* Make it work with Rails controllers
* See where the duplication appears and if it's painful
* See if limited AR reflection is helpful
* See if there's a way of ensuring everything is either a primitive or has been serialized, to make ````to_json```` safe.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
