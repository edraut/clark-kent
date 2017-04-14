require 'test_helper'

class ClarkKentTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ClarkKent
  end

  test ".bucket_name is configurable" do
    ClarkKent.config(:bucket_name => "trololo")
    assert_match "trololo", ClarkKent.bucket_name
  end
end
