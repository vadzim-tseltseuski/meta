require_relative 'memoize'

class Example
  include Memoize

  memoize def foo(i)
    "foo#{i} - #{rand(i)}"
  end

  memoize def bar
    "bar - #{rand(10)}"
  end, as: :@bar_cached
end
