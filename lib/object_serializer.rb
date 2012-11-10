require "object_serializer/version"

module ObjectSerializer
  class Serializer
    def initialize(attributes = [], &block)
      dsl = AttributeDSL.new
      dsl.instance_eval(&block)
      @attributes = attributes.dup + dsl.attributes
    end
    
    def enhance(&block)
      self.class.new(@attributes, &block)
    end
    
    def to_hash(object)
      @attributes.inject({}) do |hash, attribute|
        hash[attribute.name] = object.send(attribute.method_to_call)
        hash
      end
    end
  end
  
  class Attribute
    attr_reader :name, :method_to_call
    def initialize(name, options)
      @name = name.to_s
      @method_to_call = options[:calling] || @name
    end
  end
  
  class AttributeDSL
    attr_reader :attributes
    
    def initialize
      @attributes = []
    end
    
    def serialize(attribute, options = {})
      @attributes << Attribute.new(attribute, options)
    end
  end
end
