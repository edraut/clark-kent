module Reporting
  module Order
    include ClarkKent::ReportConfig
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
    REPORT_COLUMN_OPTIONS ||= {
      user_name: column_config(
        custom_select: "
        (SELECT u.name
          FROM users u
          WHERE u.id = orders.user_id)
        as user_name"),
      id: column_config(order_sql: 'orders.id'),
      amount: column_config(order_sql: 'orders.amount', summarizable: true),
      description: column_config(order_sql: 'orders.description')
    }

    def self.included(base)
      base.extend ClassMethods
      base.include ClarkKent::Reportable
    end

    module ClassMethods

      def user_email_arel(query, field_name, match_value)
        query = query.
          joins(:user).
          where(users: {email: match_value})
      end

    end # ClassMethods

  end
end
