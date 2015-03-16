# This migration comes from clark_kent (originally 20131226170042)
class CreateClarkKentReportFilter < ActiveRecord::Migration
  def change
    create_table :clark_kent_report_filters do |t|
    	t.integer :filterable_id
      t.string :filterable_type, :string, default: 'ClarkKent::Report'
    	t.string :filter_name
    	t.string :filter_value
      t.string :type
      t.string :duration
      t.string :kind_of_day
      t.string :offset
      t.timestamps
    end
  	add_index :clark_kent_report_filters, :filterable_id
    add_index :clark_kent_report_filters, :filterable_type
  end
end
