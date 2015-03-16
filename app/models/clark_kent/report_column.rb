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
			report.column_options_for(self.column_name).summarizable
		end

		def calculator
			('ClarkKent::' + summary_method.camelcase + 'Calculator').constantize
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