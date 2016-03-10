require 'test_helper'
require 'wired_for_change'

class WiredForChangeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::WiredForChange::VERSION
  end
end
