class ClarkKent::ReportColumnsController < ClarkKent::ApplicationController
  before_action :prepare_report_column
  before_action :prepare_report

  def new
    @report_column = ClarkKent::ReportColumn.new(report_id: @report.id)
    render partial: 'form', locals: {report_column: @report_column}
  end

  def create
    @report_column = ClarkKent::ReportColumn.new(report_column_params)
    @report_column.save
    if @report_column.errors.empty?
      render partial: 'show_wrapper', locals: {report_column: @report_column}
    else
      render partial: 'form', locals: {report_column: @report_column}, status: :conflict
    end
  end

  def show
    render partial: 'show', locals: {report_column: @report_column}
  end

  def edit
    render partial: 'form', locals: {report_column: @report_column}
  end

  def update
    @report_column.update_attributes(report_column_params)
    if @report_column.errors.empty?
      render json: {
        flash_message: "Your changes were saved.",
        html: render_to_string(partial: 'show', locals: {report_column: @report_column}) }
    else
      render partial: 'form', locals: {report_column: @report_column}, status: :conflict
    end
  end

  def destroy
    @report_column.destroy
    head :ok
  end

  protected
  def prepare_report_column
    @report_column = ClarkKent::ReportColumn.find(params[:id]) if params[:id]
  end

  def prepare_report
    report_id = params[:report_id]
    report_id ||= report_column_params[:report_id] if params[:report_column]
    @report = ClarkKent::Report.find(report_id) if report_id
    @report ||= @report_column.report if @report_column
  end

  def report_column_params
    params[:report_column].permit(:report_id, :column_name, :column_order, :report_sort, :summary_method)
  end
end
