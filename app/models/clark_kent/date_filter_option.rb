module ClarkKent
  class DateFilterOption < ReportFilterOption
    def filter_params
      [param + '_from', param + '_until']
    end
  end
end