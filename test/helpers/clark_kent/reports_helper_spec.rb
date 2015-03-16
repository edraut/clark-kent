require 'spec_helper'
require 'cgi'

describe Manage::ReportsHelper do

  describe '#print_button' do

    let(:js_close_modal) { "$('#print_report_modal').modal('hide');" }

    it 'returns nil if there are rows are nil' do
      expect(print_button(nil)).to be_nil
    end

    it 'returns a print button without modal close js' do
      rows = mock()

      expect(print_button(rows)).not_to include(js_close_modal)
    end

    it 'returns a print button without modal close js' do
      rows = mock()

      expect(print_button(rows, true)).to include(js_close_modal)
    end
  end
end