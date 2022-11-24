require 'pry'

module DSL
  class Proxy
    attr_reader :results

    def initialize(&block)
      @results = []
      instance_exec(&block)
    end

    def method_missing(name, *agrs, &block)
      @results << AttrBuilder.new(name, &block).result
    end
  end


  class AttrBuilder
    attr_reader :result

    def initialize(name, &block)
      @name = name
      @block = block
      @defult = nil
      @required = false
      @action = nil
      @enum = nil
      instance_exec(&block)
    end

    def result
      { name: @name, default: @default, required: @required, actions: @actions, enum: @enum }
    end

    def default(value = nil, &block)
      @default = block.call if block_given?
      @default ||= value
    end

    def required!
      @required = true
    end

    def actions(&block)
      action_builder = ActionBuilder.new
      action_builder.instance_exec(&block)
      @actions = action_builder.result
    end

    def enum(enum)
      @enum = enum
    end
  end

  class ActionBuilder
    attr_reader :result

    def initialize
      @result = {}
    end

    def method_missing(name, *args, &block)
      result[name] = block
    end
  end
end
