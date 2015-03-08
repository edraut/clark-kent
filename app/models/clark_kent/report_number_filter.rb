module ClarkKent
  class ReportNumberFilter < ReportFilter
    include Cloneable

  	attr_accessible :max_value, :min_value

    def filter_match_params
      [[self.min_param_name,self.min_value],[self.max_param_name,self.max_value]]
    end

    def min_param_name
      "#{self.filter_name}_min"
    end

    def max_param_name
      "#{self.filter_name}_max"
    end

  end
end