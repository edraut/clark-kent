require 'test_helper'

module ClarkKent
  class ReportsControllerTest < ActionController::TestCase
    setup do
      @report = reports(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:reports)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create report" do
      assert_difference('Report.count') do
        post :create, report: { name: @report.name, resource_type: @report.resource_type, sharing_scope_id: @report.sharing_scope_id, sharing_scope_type: @report.sharing_scope_type }
      end

      assert_redirected_to report_path(assigns(:report))
    end

    test "should show report" do
      get :show, id: @report
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @report
      assert_response :success
    end

    test "should update report" do
      patch :update, id: @report, report: { name: @report.name, resource_type: @report.resource_type, sharing_scope_id: @report.sharing_scope_id, sharing_scope_type: @report.sharing_scope_type }
      assert_redirected_to report_path(assigns(:report))
    end

    test "should destroy report" do
      assert_difference('Report.count', -1) do
        delete :destroy, id: @report
      end

      assert_redirected_to reports_path
    end
  end
end
