class Department < ActiveRecord::Base
  has_many :users
  has_many :clark_kent_reports, as: :sharing_scope, class_name: '::ClarkKent::Report'
end