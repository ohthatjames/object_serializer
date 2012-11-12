require 'spec_helper'

describe ObjectSerializer::Serializer do
  Person = Struct.new(:first_name, :last_name, :company, :catchphrases)
  Company = Struct.new(:name)
  Catchphrase = Struct.new(:phrase)
  
  let(:fred) do
    Person.new("Fred", 
               "Flintstone", 
               Company.new("Slate Rock and Gravel Company"),
               [Catchphrase.new("Yabba Dabba Do!"), Catchphrase.new("WILMA!!!")]) 
  end
  
  let(:person_serializer) do
    ObjectSerializer::Serializer.new do |s|
      s.serialize :first_name
    end
  end
  
  it "serializes only the fields defined in the serializer" do
    person_serializer.to_hash(fred).should == {"first_name" => "Fred"}
  end
  
  it "allows adding extra attributes" do
    person_serializer.serialize :last_name
    person_serializer.to_hash(fred).should == {"first_name" => "Fred", "last_name" => "Flintstone"}
  end
  
  it "allows extension of serializers to add extra options" do
    full_name_serializer = person_serializer.copy_and_extend do |s|
      s.serialize :last_name
    end
    full_name_serializer.to_hash(fred).should == {"first_name" => "Fred", "last_name" => "Flintstone"}
  end
  
  it "keeps the original serializer the same after extension" do
    full_name_serializer = person_serializer.copy_and_extend do |s|
      s.serialize :last_name
    end
    person_serializer.to_hash(fred).should == {"first_name" => "Fred"}
  end
  
  it "allows a different method to be called than the attribute name" do
    serializer = ObjectSerializer::Serializer.new do |s|
      s.serialize :given_name, :calling => "first_name"
    end
    serializer.to_hash(fred).should == {"given_name" => "Fred"}
  end
  
  it "allows a block to be executed for an attribute" do
    serializer = ObjectSerializer::Serializer.new do |s|
      s.serialize :given_name, :calling => lambda {|person| person.first_name}
    end
    serializer.to_hash(fred).should == {"given_name" => "Fred"}
  end
  
  it "allows attributes to have their own serializers" do
    company_serializer = ObjectSerializer::Serializer.new do |s|
      s.serialize :name
    end
    serializer = person_serializer.copy_and_extend do |s|
      s.serialize :company, :serializer => company_serializer
    end
    
    serializer.to_hash(fred).should == { "first_name" => "Fred", "company" => {"name" => "Slate Rock and Gravel Company"}}
  end
  
  it "maps collections with custom serializers" do
    catchphrase_serializer = ObjectSerializer::Serializer.new do |s|
      s.serialize :phrase
    end
    serializer = person_serializer.copy_and_extend do |s|
      s.serialize :catchphrases, :collection => true, :serializer => catchphrase_serializer
    end
    serializer.to_hash(fred)["catchphrases"].should == [{"phrase" => "Yabba Dabba Do!"}, { "phrase" => "WILMA!!!"}]
  end
end
