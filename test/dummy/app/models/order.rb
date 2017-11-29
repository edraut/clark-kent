class Order < ActiveRecord::Base
  extend Reporting::Order
  belongs_to :user

  paginates_per 10
end