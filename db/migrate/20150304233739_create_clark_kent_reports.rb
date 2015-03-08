class CreateClarkKentReports < ActiveRecord::Migration
  def change
    create_table :clark_kent_reports do |t|
      t.string :name
      t.string :resource_type
      t.string :sharing_scope_type
      t.integer :sharing_scope_id

      t.timestamps
    end
  end
end
