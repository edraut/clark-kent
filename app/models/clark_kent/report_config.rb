module ClarkKent
  module ReportConfig
    include ClarkKent::Reportable
    def filter_config(params)
      filter_option_class = ('ClarkKent::' + ((params[:kind] + '_option').camelcase)).constantize
      filter_option_class.new(params)
    end

    def column_config(params)
      ClarkKent::ReportColumnConfig.new(params)
    end

  end
  class ReportColumnConfig
    attr_accessor :name, :order_sql, :custom_select, :link, :time_zone_column, :time_format, :summarizable, :includes, :joins, :extra_scopes, :where, :group
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

    def id
      name
    end
  end
end