class ClarkKent::ReportsController < ClarkKent::ApplicationController
  require 'csv'
  before_action :get_these_params, :prepare_filters

  def set_manage_tab
    @manage_tab = 'reports'
  end

  def index
  end

  def new
    @report = ClarkKent::Report.new
  end

  def create
    @report = ClarkKent::Report.new(report_params)
    @report.save
    if @report.errors.empty?
      render action: :edit
    else
      render action: :new, status: :conflict
    end
  end

  def show
    @report = ClarkKent::Report.where(id: params[:id]).includes(:report_columns).first
    if request.xhr?
      render partial: 'show'
    else
      prepare_params(params.permit!) if defined? prepare_params
      if params[:run_report].present?
        @these_params.each do |k,v|
          if @report.date_filter_names.detect{|fn|
            @report.filter_options_for(fn).filter_params.include? k.to_s
          }.present?
            @these_params[k] = parse_date(v)
          end
        end
        @these_params[:page] = params[:page]
        @these_params[:per] = @report.resource_class.default_per_page
        begin
          query = @report.get_query(@these_params)
        rescue ClarkKent::ReportFilterError => e
          @errors = e.message
        else
          @rows = query.page(params[:page])
          @rows.push @report.summary_row(@rows) if @report.summary_row?
        end
      end
    end
  end

  def download_link
    @report = ClarkKent::Report.where(id: params[:id]).first
    prepare_params if defined? prepare_params
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
    UpdateReport.new(@report,report_params).call
    if @report.errors.empty?
      render partial: 'show'
    else
      render partial: 'edit', status: :conflict
    end
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

  def get_these_params
    @these_params ||= params.permit!.to_h.to_hash
  end

  def report_params
    params.require(:report).permit(:name, :resource_type, :sharing_scope_id, :sharing_scope_type)
  end

  def parse_date(date_input)
    begin
      return american_parse(date_input)
    rescue ArgumentError
      begin
        return Date.parse(date_input)
      rescue ArgumentError
        return nil
      end
    end
  end

  def american_parse(string)
    string.gsub!("%2F", "/")
    month,day,year = string.split('/').map{|part| part.to_i}
    raise ArgumentError, "#{string} is not a valid date format" unless [month,day,year].all? { |c| !!c }
    year = normalize_year(year)
    Date.new(year,month,day)
  end

  def normalize_year(year)
    if year < 100
      year = year + ((Date.today.year / 100) * 100)
    end
    year
  end

end
