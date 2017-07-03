require 'test_helper'

class ClarkKentTest < ActiveSupport::TestCase
  it ".bucket_name is configurable" do
    ClarkKent.config(:bucket_name => "trololo")
    assert_match "trololo", ClarkKent.bucket_name
  end
end
