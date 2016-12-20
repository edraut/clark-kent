module ClarkKent
  class NumberFilterOption < ReportFilterOption
    def filter_params
      [param + '_min', param + '_max']
    end
  end
end