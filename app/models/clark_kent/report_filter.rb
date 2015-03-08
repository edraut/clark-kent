module ClarkKent
	class ReportFilter < ActiveRecord::Base
	  include Cloneable

	  attr_accessor :filter_value_1, :filter_value_2
		attr_accessible :filter_value_1, :filter_value_2, :report_id, :filter_name, :filter_value, :filterable_id, :filterable_type, :type
		belongs_to :filterable, polymorphic: true

		def filter_match_params
			[self.filter_match_param,self.filter_match_value]
		end

		def filter_match_param
			self.filter_name
		end

		def filter_match_value
			self.filter_value
		end

		def display_name
			self.filter_name
		end

	end
end