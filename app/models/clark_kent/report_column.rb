module ClarkKent
	class ReportColumn < ActiveRecord::Base
	  include ClarkKent::Cloneable

		SummaryMethods = ['total','average']

		belongs_to :report

		scope :sorted, -> { order("clark_kent_report_columns.column_order") }

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

		def calculator
			('ClarkKent::' + summary_method.camelcase + 'Calculator').constantize
		end

    def name
      column_name
    end

    def link
      report.column_options_for(self.name.to_sym).link
    end

    def time_zone_column
      report.column_options_for(self.name.to_sym).time_zone_column
    end

    def time_format
      report.column_options_for(self.name.to_sym).time_format
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