class ClarkKent::UserReportEmailsController < ClarkKent::ApplicationController
  before_action :prepare_user_report_email
  before_action :prepare_report_email

  def new
    @user_report_email = ClarkKent::UserReportEmail.new(report_email_id: @report_email.id)
    render partial: 'form', locals: {user_report_email: @user_report_email}
  end

  def create
    @user_report_email = ClarkKent::UserReportEmail.new(user_report_email_params)
    if @user_report_email.save
      render partial: 'show_wrapper', locals: {user_report_email: @user_report_email}
    else
      render partial: 'form', locals: {user_report_email: @user_report_email}, status: 409
    end
  end

  def show
    render partial: 'show', locals: {user_report_email: @user_report_email}
  end

  def edit
    render partial: 'form', locals: {user_report_email: @user_report_email}
  end

  def update
    @user_report_email.update_attributes(user_report_email_params)
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {user_report_email: @user_report_email}
  end

  def destroy
    @user_report_email.destroy
    render nothing: true
  end

  def prepare_user_report_email
    @user_report_email = ClarkKent::UserReportEmail.find(params[:id]) if params[:id]
  end

  def prepare_report_email
    report_email_id = params[:report_email_id]
    report_email_id ||= user_report_email_params[:report_email_id] if params[:user_report_email]
    @report_email = ClarkKent::ReportEmail.find(report_email_id) if report_email_id
    @report_email ||= @user_report_email.report_email if @user_report_email
  end

  protected

  def user_report_email_params
    params[:user_report_email].permit(:user_id, :report_email_id, :email)
  end
end