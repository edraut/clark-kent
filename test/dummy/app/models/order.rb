class Order < ActiveRecord::Base
  include Reporting::Order
  belongs_to :user

  paginates_per 10
end