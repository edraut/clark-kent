class ClarkKent::ReportFiltersController < ClarkKent::ApplicationController
  before_filter :prepare_report_filter
  before_filter :prepare_report, :prepare_role, :prepare_filters

  def new
    @report_filter = ClarkKent::ReportFilter.new(filterable_id: @filterable.id, filterable_type: @filterable.class.name)
    render partial: 'form', locals: {report_filter: @report_filter}
  end

  def create
    report_filter_class = @filterable.get_filter_class(params[:report_filter])
    @report_filter = report_filter_class.new(params[:report_filter])
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
    @report_filter.update_attributes(params[@report_filter.class.name.underscore])
    @ajax_flash = {notice: "Your changes were saved."}
    render partial: 'show', locals: {report_filter: @report_filter}
  end

  def destroy
    @report_filter.destroy
    render nothing: true
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

end
