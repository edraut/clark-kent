class ClarkKent::ReportFiltersController < ClarkKent::ApplicationController
  before_action :prepare_report_filter
  before_action :prepare_report

  def new
    @report_filter = ClarkKent::ReportFilter.new(filterable_id: @filterable.id, filterable_type: @filterable.class.name)
    render partial: 'form', locals: {report_filter: @report_filter}
  end

  def create
    report_filter_class = @filterable.get_filter_class(report_filter_params)
    @report_filter = report_filter_class.new(report_filter_params)
    @report_filter.save
    render partial: 'show_wrapper', locals: {report_filter: @report_filter}
  end

  def show
    render partial: 'show', locals: {report_filter: @report_filter}
  end

  def edit
    render partial: 'form', locals: {report_filter: @report_filter}
  end

  def update
    @report_filter.update_attributes(report_filter_params)
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {report_filter: @report_filter}
  end

  def destroy
    @report_filter.destroy
    head :ok
  end

  protected
  def prepare_report_filter
    @report_filter = ClarkKent::ReportFilter.find(params[:id]) if params[:id]
  end

  def prepare_report
    @filterable_id = params[:filterable_id]
    @filterable_type = params[:filterable_type]
    @filterable_id ||= params[:report_filter][:filterable_id] if params[:report_filter]
    @filterable_type ||= params[:report_filter][:filterable_type] if params[:report_filter]
    @filterable_class = @filterable_type.constantize if @filterable_type
    @filterable = @filterable_class.find(@filterable_id) if @filterable_id and @filterable_class
    @filterable ||= @report_filter.filterable if @report_filter
  end

  def report_filter_params
    if @report_filter
      these_params = params[@report_filter.class.name.underscore.gsub(/.*\//,'')]
    else
      these_params = params[:report_filter]
    end
    these_params.permit(:filterable_id, :filterable_type, :string, :filter_name, :filter_value, :type, :duration, :kind_of_day, :offset)
  end
end
