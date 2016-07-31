require 'test_helper'

module ClarkKent
  class ReportsHelperTest < ActionView::TestCase
    include ClarkKent::ApplicationHelper
    test "it displays a date" do
      tz = "Mountain Time (US & Canada)"
      now = Time.now
      now = now.in_time_zone(tz)
      col = FakeReportColumn.new(time_zone_column: :time_zone)
      datetime_display = display_for_value(
        now,
        col,
        {time_zone: "Pacific Time (US & Canada)"})
      now.time_zone.name.must_equal "Mountain Time (US & Canada)"
      datetime_display.must_equal now.in_time_zone("Pacific Time (US & Canada)").to_s
    end

    class FakeReportColumn
      attr_accessor :time_zone_column
      def initialize(params)
        self.time_zone_column = params[:time_zone_column]
      end
    end
  end
end
