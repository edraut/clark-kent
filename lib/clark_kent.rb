require "clark_kent/engine"
require 'simple_form'
require 'thin_man'
require 'aws-sdk-v1'

module ClarkKent
  mattr_accessor  :resource_options, :user_class_name, :other_sharing_scopes, :base_controller,
                  :custom_report_links, :current_user_method, :work_queue, :email_security

  def self.bucket_name
    @@bucket_name || "clark-kent"
  end

  def self.config(options)
    @@resource_options = options[:resource_options].map{|option_hash| ClarkKent::ResourceOption.new option_hash} if options.has_key? :resource_options
    @@user_class_name = options[:user_class_name]
    @@bucket_name     = options[:bucket_name]
    @@other_sharing_scopes = options[:other_sharing_scopes] || []
    base_controller_name = options[:base_controller_name]
    @@base_controller = base_controller_name.constantize if base_controller_name.present?
    @@custom_report_links = options[:custom_report_links] || []
    @@current_user_method = options[:current_user_method]
    @@work_queue = options[:work_queue]
    @@email_security = options[:email_security]
  end

  def self.user_class
    @@user_class = (@@user_class_name || "User").constantize
  end


end

class Date
  def find_day(day_name)
    if Date::DAYNAMES.include?(day_name.capitalize)
      week_start = self if [0,7].include? self.wday
      week_start ||= (self.beginning_of_week - 1.day)
      week_start + Date::DAYNAMES.index(day_name.capitalize)
    else
      self.send(day_name)
    end
  end
end
