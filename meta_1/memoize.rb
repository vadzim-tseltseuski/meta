require 'pry'

module Memoize
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def memoize(method_name, as: nil)
      cache_variable_name = as ? :"#{as}" : :"@cache_#{method_name}"
      original_method = "original_#{method_name}"

      alias_method original_method, method_name

      args_count = self.instance_method(original_method).arity

      define_method method_name do |*args|
        if instance_variable_defined?(cache_variable_name)
          cached_value = instance_variable_get(cache_variable_name)
        end

        if args_count == 0
          if !cached_value
            cached_value = send(original_method)
            instance_variable_set(cache_variable_name, cached_value)
          else
            cached_value
          end
        else

          if !cached_value.is_a?(Hash)
            cached_value = {args => send(original_method, *args)}
            self.instance_variable_set(cache_variable_name, cached_value)
          elsif !cached_value.has_key?(args)
            cached_value[args] = send(original_method, *args)
          end
            cached_value[args]
        end
      end
    end
  end
end
