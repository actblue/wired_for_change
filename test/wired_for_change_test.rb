require 'test_helper'

class WiredForChangeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::WiredForChange::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_init_a_supporter
    supporter = SalsaSupporter.new(tag: ['foo', 'bar bas'], Email: "foo@bar.com")
    refute_nil supporter
  end
end
