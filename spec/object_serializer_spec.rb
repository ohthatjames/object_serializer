require 'spec_helper'

describe ObjectSerializer::Serializer do
  Person = Struct.new(:first_name, :last_name)
  
  let(:person_serializer) do
    ObjectSerializer::Serializer.new do
      serialize :first_name
    end
  end
  
  it "serializes only the fields defined in the serializer" do
    fred = Person.new("Fred", "Flintstone")
    person_serializer.to_hash(fred).should == {"first_name" => "Fred"}
  end
  
  it "allows extension of serializers to add extra options" do
    full_name_serializer = person_serializer.enhance do
      serialize :last_name
    end
    fred = Person.new("Fred", "Flintstone")
    full_name_serializer.to_hash(fred).should == {"first_name" => "Fred", "last_name" => "Flintstone"}
  end
  
  it "keeps the original serializer the same after extension" do
    full_name_serializer = person_serializer.enhance do
      serialize :last_name
    end
    fred = Person.new("Fred", "Flintstone")
    person_serializer.to_hash(fred).should == {"first_name" => "Fred"}
  end
  
  it "allows a different method to be called than the attribute name" do
    serializer = ObjectSerializer::Serializer.new do
      serialize :given_name, :calling => "first_name"
    end
    fred = Person.new("Fred", "Flintstone")
    serializer.to_hash(fred).should == {"given_name" => "Fred"}
  end
end
