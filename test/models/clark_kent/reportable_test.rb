require 'test_helper'

class ClarkKent::ReportableTest < ActiveSupport::TestCase
  it "it adds required filters if present" do
    report = ClarkKent::Report.create(name: 'test one', resource_type: 'Order')
    query = Order.report({created_at_until: Date.today, created_at_from: Date.yesterday},report)
    assert_match('orders.user_id > 0', query.to_sql)
  end

  it "it works without any required filters" do
    report = ClarkKent::Report.create(name: 'test one', resource_type: 'TestReportable')
    query = TestReportable.report({created_at_until: Date.today, created_at_from: Date.yesterday},report)
    refute_match('orders.user_id > 0', query.to_sql)
    assert_match('SELECT "orders".*', query.to_sql)
  end

  it "doesn't blow up if order_sql is blank" do
    report = ClarkKent::Report.create(name: 'test one', resource_type: 'TestReportable')
    report_column = report.report_columns.create(column_name: :user_name, column_order: 1, report_sort: 'ascending')
    query = TestReportable.report({created_at_until: Date.today, created_at_from: Date.yesterday},report)
    refute_match('order by', query.to_sql)
  end
end

class TestReportable < ActiveRecord::Base

  self.table_name = 'orders'

  include ClarkKent::ReportConfig
  include ClarkKent::Reportable

  # This mapping tells ClarkKent how to use params for filtering a report. It is only used for pre-defined,
  # standard filtering methods provided by ClarkKent: simple_equality_arel, order_arel, before_date_arel, and after_date_arel. Params that need custom filtering should define their own arel methods that follow
  # the convention <param name>_arel(query, field_name, match_value). nb. ranges can be handled with dual params like date_before/date_after
  # or amount_below/amount_above etc.
  AREL_METHODS ||= {
    'user_id' => 'simple_equality_arel',
    'amount_above' => 'above_number_arel',
    'amount_below' => 'below_number_arel'
  }

  # These are the options for permanent filters built into a report. nb dates don't make sense as permanent report filters
  # except in the case of ClarkKent::ReportEmails.
  REPORT_DEFINITION_OPTIONS ||= ['user_id', 'created_at']

  # This is the full set of report filter options for use at report runtime. REPORT_DEFINITION_OPTIONS must refer to some subset of these
  REPORT_FILTER_OPTIONS ||= [
    filter_config(kind: 'date_filter', param: 'created_at', in_required_date_group: true),
    filter_config(kind: 'object_filter', param: 'user_id', collection: :users, label: 'user'),
    filter_config(kind: 'string_filter', param: 'user_email')
  ]

  # These are the available column options for building reports from this resource
  REPORT_COLUMN_OPTIONS ||= [
    column_config(name: :user_name,
      custom_select: "
      (SELECT u.name
        FROM users u
        WHERE u.id = orders.user_id)
      as user_name"),
    column_config(name: :id, order_sql: 'orders.id', link: :order_path),
    column_config(name: :amount, order_sql: 'orders.amount', summarizable: true),
    column_config(name: :description, order_sql: 'orders.description')
  ]

  def self.user_email_arel(query, field_name, match_value)
    query = query.
      joins(:user).
      where(users: {email: match_value})
  end

end