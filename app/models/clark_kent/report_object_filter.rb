module ClarkKent
	class ReportObjectFilter < ReportFilter
	  include Cloneable

		def get_display_value
			if self.filter_value.to_i > 0
				self.filter_class.find(self.filter_value).name
			else
				self.filter_value
			end
		end

		def filter_class
			if self.filter_name =~ /_id/
				self.filter_name.split('_')[0..-2].join('_').camelcase.constantize
			end
		end

		def display_name
			if self.filter_class.present?
				self.filter_class.name.underscore.humanize
			else
				self.filter_name
			end
		end
	end
end