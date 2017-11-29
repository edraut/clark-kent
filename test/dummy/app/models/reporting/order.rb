module Reporting
  module Order
    include ClarkKent::ReportConfig
    # This mapping tells ClarkKent how to use params for filtering a report. It is only used for pre-defined,
    # standard filtering methods provided by ClarkKent: simple_equality_arel, order_arel, before_date_arel, and after_date_arel. Params that need custom filtering should define their own arel methods that follow
    # the convention <param name>_arel(query, field_name, match_value). nb. ranges can be handled with dual params like date_before/date_after
    # or amount_below/amount_above etc.
    def arel_methods
      @@arel_method ||= {
        'user_id' => 'simple_equality_arel',
        'amount_above' => 'above_number_arel',
        'amount_below' => 'below_number_arel'
      }
    end

    # These are the options for permanent filters built into a report. nb dates don't make sense as permanent report filters
    # except in the case of ClarkKent::ReportEmails.
    def report_definition_options
      @@report_definition_options ||= ['user_id', 'created_at']
    end

    # This is the full set of report filter options for use at report runtime. REPORT_DEFINITION_OPTIONS must refer to some subset of these

    def report_filter_options
      @@report_filter_options ||= [
        filter_config(kind: 'date_filter', param: 'created_at', in_required_date_group: true),
        filter_config(kind: 'object_filter', param: 'user_id', collection: :users, label: 'user'),
        filter_config(kind: 'string_filter', param: 'user_email')
      ]
    end

    # These are the available column options for building reports from this resource
    def report_column_options
      @@report_column_options ||= [
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
    end

    def user_email_arel(query, field_name, match_value)
      query = query.
        joins(:user).
        where(users: {email: match_value})
    end

    def clark_kent_required_filters(query)
      query = query.where("orders.user_id > 0")
    end

  end # ClassMethods

end
