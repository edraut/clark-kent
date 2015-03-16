include ActiveRecord::Tasks

DatabaseTasks.database_configuration = YAML.load_file(File.join(Rails.root, 'config/database.yml'))
DatabaseTasks.db_dir = 'db'

def setup_db
  report = ClarkKent::Report.create(resource_type: 'Order')
  report.report_columns.create(column_name: 'user_name', column_order: 1)
  report.report_columns.create(column_name: 'id', column_order: 2)
  report.report_columns.create(column_name: 'amount', column_order: 3)
  report.report_columns.create(column_name: 'description', column_order: 4)
  u = User.create(name: 'Michael Hedges', email: 'taproot@gmail.com')
  Order.create(user_id: u.id, description: 'Guitar strings', amount: 1)
end

def clear_and_load_db
  real_stdout, $stdout = $stdout, StringIO.new

  DatabaseTasks.drop_current('test')
  DatabaseTasks.create_current('test')
  ActiveRecord::Migrator.migrations_paths = [ActiveRecord::Migrator.migrations_paths.first]
  DatabaseTasks.load_schema_current(ActiveRecord::Base.schema_format,File.join(Rails.root,'db/schema.rb'),'test')
ensure
  $stdout = real_stdout
end

clear_and_load_db
setup_db

