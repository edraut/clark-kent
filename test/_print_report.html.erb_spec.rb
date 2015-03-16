require "spec_helper"

describe "manage/reports/_print_report.html.erb" do
  it "displays the print button with the modal" do
    rows = nil

    assign(:rows, rows)
    render partial: "manage/reports/print_report", locals: { rows: rows }

    expect(rendered).to eq("")
  end

  it "displays the print button with the modal" do
    rows = mock()
    rows.stubs(:count).returns(50)
    rows.stubs(:total_count).returns(51)
    assign(:rows, rows)
    render partial: "manage/reports/print_report", locals: { rows: rows }

    expect(rendered).to have_selector("div#print_report_modal")
  end

  it "displays just the print button" do
    rows = mock()
    rows.stubs(:count).returns(50)
    rows.stubs(:total_count).returns(49)
    assign(:rows, rows)
    render partial: "manage/reports/print_report", locals: { rows: rows }

    expect(rendered).not_to have_selector("div#print_report_modal")
  end
end