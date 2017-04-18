require 'test_helper'

class ClarkKent::ReportsControllerTest < ControllerTest

  let(:report) {ClarkKent::Report.first}
  let(:current_user) {User.first}

  setup do
    @routes = ClarkKent::Engine.routes
    @report_email = report.report_emails.create(when_to_send: 'Monday', name: 'Owner Arrival')
  end

  it "should get index" do
    get :index, params: {current_user_id: current_user.id}
    assert_response :success
  end

  it "should get new" do
    get :new, params: {current_user_id: current_user.id}
    assert_response :success
  end

  it "should create report" do
    post :create, params:
      {report: {
            name: 'delete me', resource_type: report.resource_type,
            sharing_scope_id: report.sharing_scope_id, sharing_scope_type: report.sharing_scope_type },
            current_user_id: current_user.id}
    report = ClarkKent::Report.find_by(name: 'delete me')
    report.wont_be_nil
    report.destroy
    assert_response :success
  end

  it "should render errors during creation" do
    post :create, params:
      {report: {
            name: 'delete me', resource_type: '',
            sharing_scope_id: report.sharing_scope_id, sharing_scope_type: report.sharing_scope_type },
            current_user_id: current_user.id}
    report = ClarkKent::Report.find_by(name: 'delete me')
    report.must_be_nil
    assert_response :conflict
    @response.body.must_match 'You must choose a type.'
  end

  it "should show report" do
    get :show, params: {id: report, current_user_id: current_user.id}
    assert_response :success
  end

  it "should show report results" do
    get :show, params: {id: report, current_user_id: current_user.id, run_report: true, created_at_until: Date.today.strftime("%m/%d/%Y"), created_at_from: Date.yesterday}
    assert_response :success
    @response.body.must_match 'Guitar strings'
  end

  it "should show report run errors" do
    get :show, params: {id: report, current_user_id: current_user.id, run_report: true}
    assert_response :success
    @response.body.must_match 'At least one date range is required.'
  end

  it "should get edit" do
    get :edit, params: {id: report, current_user_id: current_user.id}
    assert_response :success
  end

  it "should update report" do
    patch :update, params: {id: report,
          report: {
            name: report.name, resource_type: report.resource_type,
            sharing_scope_id: report.sharing_scope_id, sharing_scope_type: report.sharing_scope_type },
          current_user_id: current_user.id}
    assert_response :success
  end

  it "should destroy report" do
    report = ClarkKent::Report.create(name: 'delete me', resource_type: 'Order')
    assert_difference('ClarkKent::Report.count', -1) do
      delete :destroy, params: {id: report, current_user_id: current_user.id}
    end

    assert_redirected_to reports_path
  end
end
