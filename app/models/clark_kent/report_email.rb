module ClarkKent
  class ReportEmail < ActiveRecord::Base
    include ClarkKent::Cloneable

    SEND_TIMES = {
      'Mondays' => 'Monday',
      'Tuesdays' => 'Tuesday',
      'Wednesdays' => 'Wednesday',
      'Thursdays' => 'Thursday',
      'Fridays' => 'Friday',
      'Saturdays' => 'Saturday',
      'Sundays' => 'Sunday',
      '1st of the month' => 'beginning_of_month',
      'End of the month' => 'end_of_month'
    }
    belongs_to :report
    has_many :report_filters, as: :filterable, dependent: :destroy
    has_many :report_date_filters, as: :filterable, dependent: :destroy
    has_many :user_report_emails, dependent: :destroy
    has_many :users, through: :user_report_emails

    def self.send_emails_for_today
      today = Date.ih_today
      todays_filters = []
      ['beginning_of_month','end_of_month'].each do |month_bookend|
        todays_filters.push month_bookend if today.send(month_bookend) == today
      end
      todays_filters.push  Date::DAYNAMES[today.wday]
      self.where(when_to_send: todays_filters).each do |report_email|
        report_email.send_emails
      end
    end

    def send_emails
      self.user_report_emails.each do |user_report_email|
        ConeyIsland.submit(ClarkKent::ReportEmail, :send_email, instance_id: self.id, args: [user_report_email.user_id], timeout: 300, work_queue: 'boardwalk')
      end
    end

    def send_email(user_id)
      user = ClarkKent.user_class.find(user_id)
      params = {report_result_name: "report-#{self.id}-user-#{user_id}-#{Time.now.to_formatted_s(:number)}", report_class: 'ClarkKent::ReportEmail'}
      SharingScopeKind.custom.each do |sharing_scope_kind|
        unless report.report_filters.map(&:filter_name).include? sharing_scope_kind.basic_association_id_collection_name.to_s
          associations = sharing_scope_kind.associated_containers_for(user)
          if associations.respond_to? :map
            params[sharing_scope_kind.basic_association_id_collection_name] = associations.map(&:id)
          else
            params[sharing_scope_kind.basic_association_id_collection_name] = associations.id
          end
        end
      end
      report_download_url = ClarkKent::Report.send_report_to_s3(self.id, params)
      ClarkKent::ReportMailer.report_run(self.report_id, user_id, report_download_url).deliver
    rescue ClarkKent::ReportFilterError => e
      ClarkKent::ReportMailer.report_error(self.report_id, user_id, e.message).deliver
    end

    def report_filter_params
      Hash[*self.viable_report_filters.map{|filter| filter.filter_match_params}.flatten].
        merge(order: self.report.sorter).merge(self.report.report_filter_params)
    end

    def filter_kind(filter_name)
      self.report.filter_kind(filter_name)
    end

    def viable_report_filters
      @viable_report_filters ||= report_filters.to_a.select{|rf| filter_options_for(rf.filter_name).present? }
    end

    def resource_class
      self.report.resource_class
    end

    def filter_options_for(filter_name)
      self.report.filter_options_for(filter_name)
    end

    def collection_for(filter_name)
      self.report.collection_for(filter_name)
    end

    def get_filter_class(params)
      self.report.get_filter_class(params)
    end

    def available_email_filters
      self.resource_class::REPORT_DEFINITION_OPTIONS.reject{|name, label| (self.viable_report_filters.pluck(:filter_name) + self.report.viable_report_filters.pluck(:filter_name)).include? name}
    end

    def available_filters
      self.available_email_filters
    end

    def available_filter_options
      self.available_filters.map{|id| [self.filter_options_for(id).label,id]}
    end

    def get_query(params, count = false)
      self.report.resource_class.report(params,self, count)
    end

    def period_pretty
      self.report_date_filters.map{|filter| [filter.filter_name,filter.date_display].join(' ')}.join('<br>').html_safe
    end

    def emails
      self.users.map(&:email)
    end

  end
end