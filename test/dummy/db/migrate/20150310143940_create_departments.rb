class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
    end
    add_column :users, :department_id, :integer
  end
end
