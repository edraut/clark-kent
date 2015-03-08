module ClarkKent
	class ReportColumn < ActiveRecord::Base
	  include Cloneable

		SummaryMethods = ['total','average']
		attr_accessible :report_id, :column_name, :column_order, :report_sort, :summary_method
		belongs_to :report

		scope :sorted, -> { order("clark_kent_report_columns.column_order") }

		def report_sort_pretty
			{'ascending' => 'A->Z','descending' => 'Z->A'}[self.report_sort]
		end

		def calculate_summary(values)
			return nil unless self.summary_method.present?
			values.send self.summary_method
		end

		def summarizable?
			report.column_options_for(self.column_name).respond_to? :summarizable
		end
	end
end