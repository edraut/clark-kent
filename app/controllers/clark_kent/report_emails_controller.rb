class ClarkKent::ReportEmailsController < ClarkKent::ApplicationController
  before_filter :prepare_report_email
  before_filter :prepare_report

  def new
    @report_email = ClarkKent::ReportEmail.new(report_id: @report.id)
    render partial: 'form', locals: {report_email: @report_email}
  end

  def create
    @report_email = ClarkKent::ReportEmail.new(params[:report_email])
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
    @report_email.update_attributes(params[:report_email])
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {report_email: @report_email}
  end

  def destroy
    @report_email.destroy
    render nothing: true
  end

  protected
  def prepare_report_email
    @report_email = ClarkKent::ReportEmail.find(params[:id]) if params[:id]
  end

  def prepare_report
    report_id = params[:report_id]
    report_id ||= params[:report_email][:report_id] if params[:report_email]
    @report = ClarkKent::Report.find(report_id) if report_id
    @report ||= @report_email.report if @report_email
  end

end
