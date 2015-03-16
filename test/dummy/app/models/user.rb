class User < ActiveRecord::Base
  has_many :orders
  has_many :clark_kent_reports, as: :sharing_scope, class_name: '::ClarkKent::Report'
  belongs_to :department

  def full_name
    name
  end
end