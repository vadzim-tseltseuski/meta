
class Attributes < Module
  autoload :DSL, File.join(__dir__, "dsl")

  def self.define(&block)
    results = DSL::Proxy.new(&block).results
    new(results)
  end

  def initialize(results)
    required_list = []

    results.each do |attribute|
      ivar = "@#{attribute[:name].to_sym}"



      define_method attribute[:name].to_sym do
        instance_variable_get(ivar)
      end

      define_method "#{attribute[:name].to_sym}=" do |value|
        instance_variable_set(ivar, value)
      end

      if attribute[:required]
        required_list << attribute[:name]
      end

      if attribute[:enum]
        attribute[:enum].each do |e|

          define_method "#{e}!".to_sym do
            instance_variable_set(ivar, e)
          end

          define_method "#{e}?".to_sym do
            instance_variable_get(ivar) == e
          end
        end
      end

      if attribute[:actions]
        attribute[:actions].each do |name, block|
          define_method(name, &block)
        end
      end

    end

    define_method :initialize do |**args|
       if required_list&.any? && (required_list - args.keys).any?
        raise ArgumentError, required_list
       end

       ivar_result = results.map { |r| ["@#{r[:name].to_sym}", r[:default].is_a?(Proc) ? r[:default].call : r[:default]] }

       ivar_result.each { |ivar, value| instance_variable_set(ivar, value) }
    end
  end
end
