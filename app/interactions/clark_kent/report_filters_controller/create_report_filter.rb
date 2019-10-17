class ClarkKent::ReportFiltersController::CreateReportFilter
  attr_accessor :filterable, :report_filter_params, :errors, :report_filter
  def initialize(filterable, report_filter_params)
    @filterable = filterable
    @report_filter_params = report_filter_params
    @errors = []
  end

  def create
    fetch_report_filter_class
    build_report_filter
    validate_report_filter or return false
    @report_filter.save
  end

  def build_report_filter
    @report_filter = @report_filter_class.new(report_filter_params)
  end

  def fetch_report_filter_class
    @report_filter_class = @filterable.get_filter_class(report_filter_params)
  end

  def validate_report_filter
    if @report_filter_class.to_s == "ClarkKent::ReportDateFilter"
      if !@report_filter.duration.present? || 
         !@report_filter.kind_of_day.present? ||
         !@report_filter.offset.present?
        errors << "You must specify all filter timing parameters"
        return false
      end
    end
    return true
  end
end