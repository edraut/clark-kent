module ClarkKent
  module ReportConfig
    module ClassMethods
      def filter_config(params)
        filter_option_class = ('ClarkKent::' + ((params[:kind] + '_option').camelcase)).constantize
        filter_option_class.new(params)
      end

      def column_config(params)
        ClarkKent::ReportColumnConfig.new(params)
      end
    end
    extend ClassMethods
    def self.included( other )
      other.extend( ClassMethods )
    end
  end
  class ReportColumnConfig
    attr_accessor :custom_select, :order_sql, :summarizable
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end
  end
end