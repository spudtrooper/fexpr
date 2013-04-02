require 'rubygems'
require 'test/unit'
include Test::Unit
require File.dirname(__FILE__) + '/../lib/fexpr'

class TestCase
  def assert_not_nil(o)
    if not o
      assert false,'Should not be nil'
    end
  end

  def assert_length_at_least(num,arr,thing)
    if arr.length < num
      assert false,"Not enough #{thing}s: #{arr.length} < #{num}"
    end
  end

  def assert_at_least(num,val,thing=nil)
    if val < num
      assert false,"#{thing} #{val} must be at least #{num}"
    end
  end
end
