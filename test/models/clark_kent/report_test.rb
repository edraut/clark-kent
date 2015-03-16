require 'test_helper'

  class ClarkKent::ReportTest < ActiveSupport::TestCase
    test "can't save without a sharing scope id if the sharing scope is custom" do
      report = ClarkKent::Report.new :sharing_scope_type => "Department"
      report.save
      assert_includes(report.errors.full_messages, "Sharing scope can't be blank")
    end
  end
