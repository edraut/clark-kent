require 'test_helper'

class ClarkKent::ReportColumnTest < ActiveSupport::TestCase
  let(:report) {ClarkKent::Report.first}

  it "rejects report sort if no order_sql" do
    report_column = report.report_columns.create(column_name: 'user_name', report_sort: 'ascending')
    report_column.persisted?.must_equal false
    report_column.errors.full_messages.join.must_match 'This column is not sortable'
  end

end
