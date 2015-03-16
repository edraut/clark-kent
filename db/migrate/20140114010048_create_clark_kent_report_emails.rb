class CreateClarkKentReportEmails < ActiveRecord::Migration
  def change
    create_table :clark_kent_report_emails do |t|
    	t.integer :report_id
    	t.string :when_to_send
      t.string :name
    end
  end
end
