class ClarkKent::ReportEmailsController < ClarkKent::ApplicationController
  before_action :prepare_report_email
  before_action :prepare_report

  def new
    @report_email = ClarkKent::ReportEmail.new(report_id: @report.id)
    render partial: 'form', locals: {report_email: @report_email}
  end

  def create
    @report_email = ClarkKent::ReportEmail.new(report_email_params)
    @report_email.save
    render partial: 'edit', locals: {report_email: @report_email}
  end

  def show
    render partial: 'show', locals: {report_email: @report_email}
  end

  def edit
    render partial: 'edit', locals: {report_email: @report_email}
  end

  def update
    @report_email.update_attributes(report_email_params)
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {report_email: @report_email}
  end

  def destroy
    @report_email.destroy
    head :ok
  end

  protected
  def prepare_report_email
    @report_email = ClarkKent::ReportEmail.find(params[:id]) if params[:id]
  end

  def prepare_report
    report_id = params[:report_id]
    report_id ||= report_email_params[:report_id] if params[:report_email]
    @report = ClarkKent::Report.find(report_id) if report_id
    @report ||= @report_email.report if @report_email
  end

  def report_email_params
    params[:report_email].permit(:report_id, :when_to_send, :name)
  end

end
