require "clark_kent/engine"

module ClarkKent
  mattr_accessor  :resource_options, :user_class_name, :other_sharing_scopes, :base_controller,
                  :custom_report_links

  def self.config(options)
    @@resource_options = options[:resource_options]
    @@user_class_name = options[:user_class_name]
    @@other_sharing_scopes = options[:other_sharing_scopes]
    base_controller_name = options[:base_controller_name]
    @@base_controller = base_controller_name.constantize
    @@custom_report_links = options[:custom_report_links]
  end

  def self.user_class
    @@user_class = @@user_class_name.constantize
  end

end
