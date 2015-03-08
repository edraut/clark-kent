class ClarkKent::ReportsController < ClarkKent::ApplicationController
  require 'csv'
  respond_to :html, :csv
  before_filter :prepare_filters

  def set_manage_tab
    @manage_tab = 'reports'
  end

  def index
  end

  def new
    @report = ClarkKent::Report.new
  end

  def create
    @report = ClarkKent::Report.new(params[:report])
    @report.save
    render action: :edit
  end

  def show
    @report = ClarkKent::Report.where(id: params[:id]).includes(:report_columns).first
    if request.xhr?
      render partial: 'show'
    else
      prepare_params
      if params[:run_report].present?
        @these_params[:page] = params[:page]
        @these_params[:per] = @report.resource_class.default_per_page
        query = @report.get_query(@these_params)
        @rows = query.page(params[:page])
        @rows.push @report.summary_row(@rows) if @report.summary_row?
      end
    end
  end

  def download_link
    @report = ClarkKent::Report.where(id: params[:id]).first
    prepare_params
    @report_result_name = "report-#{@report.id}-#{Time.now.to_formatted_s(:number)}"
    @these_params[:report_result_name] = @report_result_name
    ConeyIsland.submit(ClarkKent::Report,
                      :send_report_to_s3,
                      args: [@report.id, @these_params],
                      timeout: 300,
                      work_queue: 'boardwalk')
    render partial: 'download_link'
  end

  def edit
    @report = ClarkKent::Report.find(params[:id])
    if request.xhr?
      render_ajax
    end
  end

  def update
    @report = ClarkKent::Report.find(params[:id])
    @report.update_attributes(params[:report])
    render partial: 'show'
  end

  def clone
    report = ClarkKent::Report.find(params[:id])
    report.deep_clone
    redirect_to reports_url
  end

  def destroy
    @report = ClarkKent::Report.find(params[:id])
    @report.destroy
    redirect_to reports_url
  end

  protected

end
