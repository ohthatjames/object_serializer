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
        hash[attribute] = object.send(attribute)
        hash
      end
    end
  end
  
  class AttributeDSL
    attr_reader :attributes
    
    def initialize
      @attributes = []
    end
    
    def serialize(attribute)
      @attributes << attribute.to_s
    end
  end
end
