class CreateClarkKentReportColumn < ActiveRecord::Migration
  def change
    create_table :clark_kent_report_columns do |t|
    	t.integer :report_id
    	t.string :column_name
    	t.integer :column_order
    	t.string :report_sort
      t.string :summary_method
    end
  	add_index :clark_kent_report_columns, :report_id
  end
end
