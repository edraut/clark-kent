require 'test_helper'

  class ClarkKent::ReportEmailTest < ActiveSupport::TestCase
    test "sends report to s3" do
      ClarkKent.config(bucket_name: "clark-kent-test")
      user = User.find_by(email: 'taproot@gmail.com')
      report = ClarkKent::Report.first
      report.update_columns(sharing_scope_type: 'Department', sharing_scope_id: user.department_id)
      report_email = report.report_emails.create(name: 'test_emailer')
      report_email.report_filters.create(
        filter_name: "created_at",
        filter_value: nil,
        type: "ClarkKent::ReportDateFilter",
        duration: "week",
        kind_of_day: "Monday",
        offset: "this_week")
      bucket_mock = ->(string) { raise 'finished building report'}
      err = assert_raises(RuntimeError) do
        AWS::S3::Bucket.stub :new, bucket_mock, [String] do
          report_email.send_email(user.id)
        end
      end
      err.message.must_match('finished building report')
    end

    test "throws an error if required date filters are not present" do
      user = User.find_by(email: 'taproot@gmail.com')
      report = ClarkKent::Report.first
      report.update_columns(sharing_scope_type: 'Department', sharing_scope_id: user.department_id)
      report_email = report.report_emails.create(name: 'test_emailer')
      report_email.send_email(user.id)
      mailed = ActionMailer::Base.deliveries.last
      assert_match /Your report could not be created due to the following problem/, mailed.body.to_s
      assert_match /At least one date range is required/, mailed.body.to_s
    end
  end
