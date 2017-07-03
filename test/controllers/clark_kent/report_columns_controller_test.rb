require 'test_helper'

class ClarkKent::ReportColumnsControllerTest < ControllerTest
  include Rails.application.routes.mounted_helpers
  let(:report) {ClarkKent::Report.first}

  it "should create a report column" do
    post clark_kent.report_columns_path(report_column: {report_id: report.id, column_name: 'user_name'}), xhr: true
    assert_response :success
  end

  it "should reject a report column with no column_name" do
    post clark_kent.report_columns_path(report_column: {report_id: report.id}), xhr: true
    assert_response :conflict
    @response.body.must_match /can[^t]*t be blank/
  end

  it "should reject a report column with unusable sort" do
    post clark_kent.report_columns_path( report_column: {
          report_id: report.id, column_name: 'user_name', report_sort: 'ascending'} ), xhr: true
    assert_response :conflict
    @response.body.must_match 'This column is not sortable.'
  end

end