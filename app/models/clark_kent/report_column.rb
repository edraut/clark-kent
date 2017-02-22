module ClarkKent
	class ReportColumn < ActiveRecord::Base
	  include ClarkKent::Cloneable

		SummaryMethods = ['total','average']

		belongs_to :report

		scope :sorted, -> { order("clark_kent_report_columns.column_order") }
    validates :column_name, presence: true
    validates_with ReportColumnValidator
    
		def report_sort_pretty
			{'ascending' => 'A->Z','descending' => 'Z->A'}[self.report_sort]
		end

		def calculate_summary(values)
			return nil unless self.summary_method.present?
			calculator.new(values).calculate
		end

		def summarizable?
			report.column_options_for(self.column_name.to_sym).summarizable
		end

    def sortable?
      config_options.order_sql.present?
    end

		def calculator
			('ClarkKent::' + summary_method.camelcase + 'Calculator').constantize
		end

    def name
      column_name
    end

    def config_options
      report.column_options_for(self.name.to_sym)
    end

    def link
      config_options.link
    end

    def time_zone_column
      config_options.time_zone_column
    end

    def time_format
      config_options.time_format
    end
	end

	class AbstractCalculator
    def initialize values
    	@values = values
    end
	end

	class TotalCalculator < AbstractCalculator
    def calculate
    	@values.sum
    end
	end

	class AverageCalculator < AbstractCalculator
    def calculate
    	if @values.length < 1
        return nil
      else
        return (@values.sum.to_f / @values.length)
      end
    end
	end
end