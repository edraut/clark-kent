require 'test_helper'

module ClarkKent
  class ReportsControllerTest < ActionController::TestCase
    setup do
      @report = ClarkKent::Report.first
      @routes = Engine.routes
      @current_user = User.first
    end

    test "should get index" do
      get :index, current_user_id: @current_user.id
      assert_response :success
    end

    test "should get new" do
      get :new, current_user_id: @current_user.id
      assert_response :success
    end

    test "should create report" do
      assert_difference('Report.count') do
        post :create,
          report: {
            name: 'delete me', resource_type: @report.resource_type,
            sharing_scope_id: @report.sharing_scope_id, sharing_scope_type: @report.sharing_scope_type },
          current_user_id: @current_user.id
      end
      report = Report.find_by(name: 'delete me')
      report.destroy
      assert_response :success
    end

    test "should show report" do
      get :show, id: @report, current_user_id: @current_user.id
      assert_response :success
    end

    test "should show report results" do
      get :show, id: @report, current_user_id: @current_user.id, run_report: true, created_at_until: Date.today, created_at_from: Date.yesterday
      assert_response :success
      assert_not_nil assigns(:rows)
      @response.body.must_match 'Guitar strings'
    end

    test "should show report run errors" do
      get :show, id: @report, current_user_id: @current_user.id, run_report: true
      assert_response :success
      @response.body.must_match 'At least one date range is required.'
    end

    test "should get edit" do
      get :edit, id: @report, current_user_id: @current_user.id
      assert_response :success
    end

    test "should update report" do
      patch :update, id: @report,
        report: {
          name: @report.name, resource_type: @report.resource_type,
          sharing_scope_id: @report.sharing_scope_id, sharing_scope_type: @report.sharing_scope_type },
        current_user_id: @current_user.id
      assert_response :success
    end

    test "should destroy report" do
      report = Report.create(name: 'delete me', resource_type: 'Order')
      assert_difference('Report.count', -1) do
        delete :destroy, id: report, current_user_id: @current_user.id
      end

      assert_redirected_to reports_path
    end
  end
end
