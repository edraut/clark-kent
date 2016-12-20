module ClarkKent
	class ReportFilterOption

		attr_accessor :param, :label, :collection, :kind, :select, :in_required_date_group, :date_requirement_override

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

		def label
			@label || @param
		end
	end
end