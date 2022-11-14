require 'pry'

module Memoize
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def memoize(method_name, as: nil)
      cache_variable_name = as ? :"#{as}" : :"@cached_#{method_name}"
      cached_args = :"@__cached_#{method_name}"

      original_method = "original_#{method_name}"

      alias_method original_method, method_name

      args_count = self.instance_method(original_method).arity

      if args_count == 0
        define_method method_name do
          if instance_variable_defined?(cache_variable_name)
            return instance_variable_get(cache_variable_name)
          else
            instance_variable_set(cache_variable_name, __send__(original_method))
          end
        end
      else
        define_method method_name do |*args|
          key = args.hash
          cache = {}

          if instance_variable_defined?(cache_variable_name)
            cache = instance_variable_get(cached_args) || {}
            return instance_variable_set(cache_variable_name, cache[key]) if cache.key?(key)

            cache[key] = __send__(original_method, *args)
            cache.shift if cache.size > 100 # optional memory leak guard
          else
            cache[key] = __send__(original_method, *args)
          end

          instance_variable_set(cache_variable_name, cache[key])
          instance_variable_set(cached_args, cache)
          cache[key]
        end
      end
    end
  end
end
