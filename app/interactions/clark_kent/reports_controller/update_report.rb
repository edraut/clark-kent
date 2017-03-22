class ClarkKent::ReportsController::UpdateReport
  def initialize(report, params)
    @report, @params = report, params
  end

  def call
    @report.assign_attributes(@params)
    validate_resource_type or return false
    @report.save
  end

  def validate_resource_type
    if @report.report_columns.any? || @report.report_filters.any?
      if @report.changes.keys.include? 'resource_type'
        @report.errors[:resource_type] << "You can't change the type of report after adding columns or filters."
        return false
      end
    end
    return true
  end
end