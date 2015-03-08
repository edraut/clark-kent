class ClarkKent::ReportColumnsController < ClarkKent::ApplicationController
  before_filter :prepare_report_column
  before_filter :prepare_report

  def new
    @report_column = ClarkKent::ReportColumn.new(report_id: @report.id)
    render partial: 'form', locals: {report_column: @report_column}
  end

  def create
    @report_column = ClarkKent::ReportColumn.new(params[:report_column])
    @report_column.save
    render partial: 'show_wrapper', locals: {report_column: @report_column}
  end

  def show
    render partial: 'show', locals: {report_column: @report_column}
  end

  def edit
    render partial: 'form', locals: {report_column: @report_column}
  end

  def update
    @report_column.update_attributes(params[:report_column])
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {report_column: @report_column}
  end

  def destroy
    @report_column.destroy
    render nothing: true
  end

  protected
  def prepare_report_column
    @report_column = ClarkKent::ReportColumn.find(params[:id]) if params[:id]
  end

  def prepare_report
    report_id = params[:report_id]
    report_id ||= params[:report_column][:report_id] if params[:report_column]
    @report = ClarkKent::Report.find(report_id) if report_id
    @report ||= @report_column.report if @report_column
  end

end
