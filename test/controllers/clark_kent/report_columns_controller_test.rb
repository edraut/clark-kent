require 'test_helper'

class ClarkKent::ReportColumnsControllerTest < ControllerTest

  let(:report) {ClarkKent::Report.first}

  setup do
    @routes = ClarkKent::Engine.routes
  end

  it "should create a report column" do
    xhr :post, :create, params: {report_column: {report_id: report.id, column_name: 'user_name'}}
    assert_response :success
  end

  it "should reject a report column with no column_name" do
    xhr :post, :create, params: {report_column: {report_id: report.id}}
    assert_response :conflict
    @response.body.must_match /can[^t]*t be blank/
  end

  it "should reject a report column with unusable sort" do
    xhr :post, :create, params: {report_column: {report_id: report.id, column_name: 'user_name', report_sort: 'ascending'}}
    assert_response :conflict
    @response.body.must_match 'This column is not sortable.'
  end

end