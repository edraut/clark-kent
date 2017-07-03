require 'test_helper'

class ClarkKent::ReportFiltersControllerTest < ControllerTest
  include Rails.application.routes.mounted_helpers

  setup do
    @report = ClarkKent::Report.first
    @report_email = @report.report_emails.create(when_to_send: 'Monday', name: 'Owner Arrival')
    @current_user = User.first
  end

  test "it should create a report filter" do
    post clark_kent.report_filters_path(report_filter: {filterable_id: @report.id, filterable_type: "ClarkKent::Report", filter_name: "user_email", filter_value: "taproot@gmail.com"})
    assert_response :success
    report_filter = ClarkKent::ReportFilter.order(id: :desc).first
    report_filter.type.must_equal 'ClarkKent::ReportStringFilter'
  end

  test "it should create an object report filter" do
    post clark_kent.report_filters_path(report_filter: {filterable_id: @report.id, filterable_type: "ClarkKent::Report", filter_name: "user_id", filter_value: @current_user.id})
    assert_response :success
    report_filter = ClarkKent::ReportFilter.order(id: :desc).first
    report_filter.type.must_equal 'ClarkKent::ReportObjectFilter'
  end

  test "it should create a date report filter" do
    post clark_kent.report_filters_path(report_filter: {filterable_id: @report_email.id, filterable_type: "ClarkKent::Report", filter_name: 'created_at', duration: 'week', kind_of_day: 'Monday', offset: 'last_week'})
    assert_response :success
    report_filter = ClarkKent::ReportFilter.order(id: :desc).first
    report_filter.type.must_equal 'ClarkKent::ReportDateFilter'
  end

  test "should get the edit form for a string filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportStringFilter', filter_name: "user_email", filter_value: "taproot@gmail.com")
    get clark_kent.edit_report_filter_path(filter.id)
    assert_response :success
  end

  test "should get the edit form for an object filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportObjectFilter', filter_name: "user_id", filter_value: @current_user.id)
    get clark_kent.edit_report_filter_path(filter.id)
    assert_response :success
  end

  test "should get the edit form for a date filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportDateFilter', filter_name: 'created_at', duration: 'week', kind_of_day: 'Monday', offset: 'last_week')
    get clark_kent.edit_report_filter_path(filter.id)
    assert_response :success
  end

  test "should get the show view for a string filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportStringFilter', filter_name: "user_email", filter_value: "taproot@gmail.com")
    get clark_kent.report_filter_path(filter.id)
    assert_response :success
  end

  test "should get the show view for an object filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportObjectFilter', filter_name: "user_id", filter_value: @current_user.id)
    get clark_kent.report_filter_path(filter.id)
    assert_response :success
  end

  test "should get the show view for a date filter" do
    filter = @report_email.report_filters.create(type: 'ClarkKent::ReportDateFilter', filter_name: 'created_at', duration: 'week', kind_of_day: 'Monday', offset: 'last_week')
    get clark_kent.report_filter_path(filter.id)
    assert_response :success
  end
end
