require_relative 'lib/attributes'

class Foo
  include ( Attributes.define do
    name do
      required!
    end
    state do
      enum %i[pending running stopped failed]
      default :pending
    end
    started_at { default { Time.now } }
    count do
      default 0
      actions do
        incr! do
          @count += 1
        end
        decr! do
          @count -= 1
        end
      end
    end
  end)
end