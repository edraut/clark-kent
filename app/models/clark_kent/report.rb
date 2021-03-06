module ClarkKent
require 'aws-sdk-v1'
  # load the builders
  Dir.glob(Rails.root.join('app/models/reporting/*.rb')) { |file| load file }
  class Report < ActiveRecord::Base
    include ClarkKent::Cloneable
    include ForeignOffice::Broadcaster

    require_channel_presence


    SortDirections = {'ascending' => 'asc', 'descending' => 'desc'}

    attr_accessor :summary_row_storage, :report_result_url, :browser_tab_id

    belongs_to :sharing_scope, polymorphic: true
    has_many :report_filters, as: :filterable, dependent: :destroy
    has_many :report_columns, -> {order("clark_kent_report_columns.column_order").references(:report_columns)}, dependent: :destroy
    has_many :report_emails, dependent: :destroy
    has_many :report_email_filters, through: :report_emails, source: :report_filters

    scope :for, ->(resource_type) { where(resource_type: resource_type) }
    scope :shared, -> { where(sharing_scope_id: nil) }

    validates :sharing_scope_id, presence: true, if: ->(r) { r.sharing_scope_type.present? }
    validates :resource_type, presence: {message: 'You must choose a type.'}, allow_blank: false

    def self.send_report_to_s3(report_id, params)
      report_class = params[:report_class].constantize if params[:report_class]
      report_class ||= ::ClarkKent::Report

      reportable = report_class.find(report_id)
      is_email = 'ClarkKent::ReportEmail' == report_class.name
      report = is_email ? reportable.report : reportable
      query = reportable.get_query(params)
      row_count = reportable.get_query(params, true)
      bucket = AWS::S3::Bucket.new(ClarkKent.bucket_name)
      report_destination = bucket.objects[params[:report_result_name]]
      byte_count = 0
      temp_buffer = report.headers.to_csv
      offset = 0
      summary_rows = []
      some_left = true
      report_destination.write(estimated_content_length: row_count * 1000) do |buffer, bytes|
        while temp_buffer.length < bytes and some_left
          this_batch = query.offset(offset).limit(100)
          some_left = this_batch.each do |row|
            temp_buffer << report.report_columns.map{ |column| row[column.column_name] }.to_csv
          end.any?
          summary_rows.push report.summary_row(this_batch) if report.summary_row? and some_left
          offset += 100
        end
        if report.summary_row_storage.blank? and (!some_left)
          if report.summary_row? and summary_rows.any?
            summary_row_map = report.summary_row(summary_rows)
            report.summary_row_storage = report.report_columns.map do |col|
              summary_row_map.send col.column_name
            end
            temp_buffer << report.summary_row_storage.to_csv
          end
        end
        if temp_buffer.present?
          chunk = temp_buffer.slice!(0...bytes)
          buffer << chunk
        end
      end
      report.report_result_url = report_destination.url_for(
        :read,
        secure: true,
        response_content_type: 'text/csv',
        response_content_encoding: 'binary',
        response_content_disposition: 'attachment',
        expires: 60*60*24*30 #good for 30 days
      )
      if 'ClarkKent::Report' == report_class.name
        report.browser_tab_id = params[:browser_tab_id]
        report.broadcast_change
      end
      if is_email && 'login_required' == ClarkKent.email_security
        params[:report_result_name]
      else
        report.report_result_url.to_s
      end
    end

    def viable_report_columns
      @viable_report_columns ||= report_columns.to_a.select{|rc| column_options_for(rc.column_name).present? }
    end

    def viable_report_filters
      @viable_report_filters ||= report_filters.to_a.select{|rf| filter_options_for(rf.filter_name).present? }
    end

    def get_query(params, count = false)
      self.resource_class.report(params,self, count)
    end

    def resource_class
      @resource_class ||= self.resource_type.constantize
    end

    ## This ephemeral class allows us to create a row object that has the same attributes as the AR response
    ## to the query, including all the custom columns defined in the resource class report config.
    ## currently only used for the summary row, since we can't get that in the same AR query and have to
    ## add it to the collection after the query returns.
    def row_class
      report_columns = viable_report_columns
      @row_class ||= Class.new do
        report_columns.each do |report_column|
          attr_accessor report_column.column_name.to_sym
        end

        def initialize params = {}
          params.each { |key, value| send "#{key}=", value }
        end

        def [](key)
          self.send key
        end
      end
    end

    def sort_column
      @sort_column ||= viable_report_columns.detect{|rc| rc.report_sort.present?}
    end

    def sorter
      if self.sort_column
        sort_column_name = self.sort_column.column_name
        sort_direction = Report::SortDirections[sort_column.report_sort]
        ReportSort.new(order_column: sort_column_name, order_direction: sort_direction)
      end
    end

    def arel_includes
      viable_report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.includes
        }.compact
    end

    def arel_joins
      viable_report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.joins
        }.compact
    end

    def extra_scopes
      viable_report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.extra_scopes
        }.flatten.compact
    end

    def extra_filters
      viable_report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.where
        }.flatten.compact
    end

    def groups
      viable_report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.group
        }.flatten.compact
    end

    ## These are the built-in filter params that define this report. They are merged at a later
    ## step with the runtime params entered by the user for a specific report run.
    ## nb. the sorter column here may be overridden by a runtime sort if requested by the user.
    def report_filter_params
      Hash[*viable_report_filters.map{|filter| filter.filter_match_params}.flatten].
        merge(order: self.sorter)
    end

    def select_clauses
      @selects = []
      viable_report_columns.each do |report_column|
        column_option = self.column_options_for(report_column.column_name)
        @selects.push column_option.custom_select if column_option.present? && column_option.custom_select.present?
      end
      viable_report_filters.each do |report_filter|
        column_option = self.column_options_for(report_filter.filter_name.to_sym)
        @selects.push column_option.custom_select if column_option.present? && column_option.custom_select.present?
      end
      @selects
    end

    def filter_options_for(filter_name)
      self.resource_class.report_filter_options.detect{|filter| filter.param == filter_name}
    end

    def column_options
      @column_options ||= self.resource_class.report_column_options
    end

    def column_options_for(column_name)
      if column_options.any?{|co| co.name == column_name.to_sym}
        column_options.detect{|co| co.name == column_name.to_sym}
      else
        column_name = column_name.to_s.split('_')[0..-2].join('_')
        if column_options.any?{|co| co.name ==  column_name.to_sym}
          column_options.detect{|co| co.name == column_name.to_sym}
        end
      end
    end

    def filter_kind(filter_name)
      self.filter_options_for(filter_name).kind
    end

    def date_filter_names
      self.resource_class.report_filter_options.select{|filter| 'date_filter' == filter.kind}.map{|filter| filter.param}
    end

    ## These are the filters available for defining a report for this resource. They do not include date
    ## filters as those only make sense at runtime, or in an auto-generated, timed emailed report.
    def available_filters
      self.available_email_filters.reject{|name| self.date_filter_names.include? name}
    end

    def available_filter_options
      self.available_filters.map{|filter_name| [self.filter_options_for(filter_name).label,filter_name]}
    end

    ## This is the full set of filter options for defining a report, including the date filters for
    ## an automatic, timed, emailed report.
    def available_email_filters
      self.resource_class.report_definition_options.reject{|name| (viable_report_filters.map(&:filter_name)).include? name}
    end

    def collection_for(filter_name)
      self.filter_options_for(filter_name).collection
    end

    ## These are the filters available at runtime, ie. not including the ones set to define this report.
    ## If updating the report, this is the set available to add as new report definition filters.
    def custom_filters
      self.resource_class.report_filter_options.select{|filter| viable_report_filters.map(&:filter_name).exclude? filter.param}
    end

    ## This is the set of columns not chosed to use in the report. These are the ones available to add
    ## when updating a report.
    def available_columns
      column_options.reject{|column| viable_report_columns.map(&:column_name).include? column.name.to_s}
    end

    def sortable?(column)
      column_info = self.column_options_for(column.column_name)
      column_info.present? && column_info.order_sql.present?
    end

    def sharing_scope_pretty
      (self.sharing_scope.try :name ) || 'Everyone'
    end

    def resource_type_pretty
      if self.resource_class.respond_to? :prettify_name
        self.resource_class.prettify_name.pluralize
      else
        self.resource_class.name.humanize
      end
    end

    def get_filter_class(params)
      filter_option = self.resource_class.report_filter_options.detect{|filter| filter.param == params[:filter_name]}
      "ClarkKent::Report#{filter_option.kind.camelcase}".constantize
    end

    def summary_row_values(rows)
      viable_report_columns.each_with_index.map do |report_column,index|
        report_column.calculate_summary(rows.map{|row| row[index]})
      end
    end

    def summary_row(rows)
      row_array = viable_report_columns.map do |report_column|
        [report_column.column_name,report_column.calculate_summary(rows.map{|row| row.send(report_column.column_name)})]
      end
      row_class.new(row_array.to_h)
    end

    def summary_row?
      @summary_row_presence ||= viable_report_columns.any?{|c| c.summary_method.present? }
    end

    def headers
      the_headers = viable_report_columns.sort_by{|c| c.column_order || 100}.map(&:column_name)

      unless name =~ /net\s?promoter/i
        the_headers.map(&:humanize)
      else
        the_headers
      end
    end

    def deep_clone
      Report.transaction do
        new_report = dup.reset_timestamps
        new_report.name << " CLONED: #{Date.today.to_s(:db)}"
        new_report.save!

        report_filters.each do |report_filter|
          new_report.report_filters << report_filter.dup.reset_timestamps
        end

        report_columns.each do |report_column|
          new_report.report_columns << report_column.dup.reset_timestamps
        end

        report_emails.each do |report_email|
          new_report_email = report_email.dup.reset_timestamps
          new_report.report_emails << new_report_email

          report_email.report_filters.each do |report_filter|
            new_report_email.report_filters << report_filter.dup.reset_timestamps
          end

          report_email.user_report_emails.each do |user_report_email|
            new_report_email.user_report_emails << user_report_email.dup.reset_timestamps
          end
        end

        new_report
      end
    end

    def serialize
      { report_result_url: self.report_result_url,
        browser_tab_id: self.browser_tab_id
      }
    end
  end

  class ReportSort
    attr_accessor :order_column, :order_direction

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end
  end

end
