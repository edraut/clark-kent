module ClarkKent
  class ReportDateFilter < ReportFilter
    WeekDayOptions = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
    MonthDayOptions = ['beginning of month']
    DayOptions = WeekDayOptions + MonthDayOptions
    WeekPeriodOptions = {
      'previous week' => 'last_week',
      'same week' => 'this_week',
      'following week' => 'next_week'
    }
    MonthPeriodOptions = {
      'previous month' => 'last_month',
      'same month' => 'this_month',
      'following month' => 'next_month'
    }

    PeriodOptions = WeekPeriodOptions.merge MonthPeriodOptions

    Durations = ['day','week','two weeks','month']

    before_save :handle_filter_value

    def filter_match_params
      [[self.begin_param_name,self.begin_date],[self.end_param_name,self.end_date]]
    end

    def begin_param_name
      "#{self.filter_name}_from"
    end

    def end_param_name
      "#{self.filter_name}_until"
    end

    def begin_date
      @begin_date = Date.ih_today
      direction, period = self.period_offset
      @begin_date = @begin_date.send(direction, 1.send(period)) if direction
      @begin_date = @begin_date.find_day(self.day_offset) if self.day_offset
      @begin_date
    end

    def day_offset
      return false if 'today' == self.kind_of_day
      self.kind_of_day.gsub(/ /,'_')
    end

    def period_offset
      direction, period = self.offset.split('_')
      direction = {'last' => '-', 'next' => '+', 'this' => false, '' => false}[direction.to_s]
      return [direction, period]
    end

    def end_date
      return self.begin_date if 'day' == self.duration
      return self.begin_date + 6.days if 'week' == self.duration
      return self.begin_date + 13.days if 'two weeks' == self.duration
      if Date::DAYNAMES.include? self.kind_of_day.capitalize
        return self.begin_date + 1.month
      else
        return self.begin_date.end_of_month
      end
    end

    def handle_filter_value
      if self.filter_value_1.present? and self.filter_value_2.present?
        self.filter_value = [filter_value_1, self.filter_value_2].join(' ')
      end
    end

    def offset_pretty
      self.class::PeriodOptions.rassoc(self.offset).first
    end

    def date_display
      "starts on #{self.kind_of_day} #{self.offset_pretty} for 1 #{self.duration}"
    end
  end
end