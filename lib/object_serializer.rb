require "object_serializer/version"

module ObjectSerializer
  class Serializer
    def initialize(attributes = [], &block)
      @attributes = attributes.dup
      dsl = AttributeDSL.new(self)
      dsl.instance_eval(&block)
    end
    
    def serialize(attribute, options = {})
      @attributes << Attribute.new(attribute, options)
    end
    
    def copy_and_extend(&block)
      self.class.new(@attributes, &block)
    end
    
    def to_hash(object)
      @attributes.inject({}) do |hash, attribute|
        hash[attribute.name] = attribute.process(object)
        hash
      end
    end
  end
  
  class Attribute
    attr_reader :name
    def initialize(name, options)
      @name = name.to_s
      @method_or_block_to_call = options[:calling] || @name
      @serializer = options[:serializer]
      @collection = !!options[:collection]
    end
    
    def process(object)
      serialized_value(value_from(object))
    end
    
    private
    def serialized_value(value)
      if @collection
        value.map {|v| serialized_individual_value(v) }
      else
        serialized_individual_value(value)
      end
    end
    
    def serialized_individual_value(value)
      if @serializer
        @serializer.to_hash(value)
      else
        value
      end
    end
    
    def value_from(object)
      if @method_or_block_to_call.respond_to?(:call)
        @method_or_block_to_call.call(object)
      else
        object.send(@method_or_block_to_call)
      end
    end
  end
  
  class AttributeDSL
    def initialize(attribute_owner)
      @attribute_owner = attribute_owner
    end
    
    def serialize(attribute, options = {})
      @attribute_owner.serialize(attribute, options)
    end
  end
end
