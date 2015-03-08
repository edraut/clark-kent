module ClarkKent
  # load the builders
  Dir.glob(Rails.root.join('app/models/reporting/*.rb')) { |file| load file }
  class Report < ActiveRecord::Base

    include Cloneable

    SortDirections = {'A->Z' => 'asc', 'Z->A' => 'desc'}

    attr_accessible :resource_type, :name, :sharing_scope_id, :sharing_scope_type
    attr_accessor :summary_row_storage

    belongs_to :sharing_scope, polymorphic: true
    has_many :report_filters, as: :filterable, dependent: :destroy
    has_many :report_columns, -> {order("clark_kent_report_columns.column_order").references(:report_columns)}, dependent: :destroy
    has_many :report_emails, dependent: :destroy
    has_many :report_email_filters, through: :report_emails, source: :report_filters

    scope :for, ->(resource_type) { where(resource_type: resource_type) }
    scope :shared, -> { where(sharing_scope_id: nil) }

    validates :sharing_scope_id, presence: true, if: ->(r) { r.sharing_scope_type.present? }

    def self.send_report_to_s3(report_id, params)
      params = params
      report_class = params['report_class'].constantize if params['report_class']
      report_class ||= ::ClarkKent::Report
      reportable = report_class.find(report_id)
      report = ('ClarkKent::ReportEmail' == report_class.name) ? reportable.report : reportable
      query = reportable.get_query(params)
      row_count = reportable.get_query(params, true)
      bucket = AWS::S3::Bucket.new(ClarkKent::ReportUploaderBucketName)
      report_destination = bucket.objects[params['report_result_name']]
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
      report_result_url = report_destination.url_for(
        :read,
        secure: true,
        response_content_type: 'text/csv',
        response_content_encoding: 'binary',
        expires: 60*60*24*30 #good for 30 days
      )
      if 'ClarkKent::Report' == report_class.name
        ForeignOffice.publish(channel: params['report_result_name'], object: {report_result_url: report_result_url.to_s} )
      end
      report_result_url.to_s
    end

    def get_query(params, count = false)
      self.resource_class.report(params,self, count)
    end

    def resource_class
      @resource_class ||= self.resource_type.constantize
    end

    def sort_column
      @sort_column ||= self.report_columns.where("clark_kent_report_columns.report_sort is not NULL and clark_kent_report_columns.report_sort != ''").first
    end

    def sorter
      if self.sort_column
        sort_column_name = self.sort_column.column_name
        sort_direction = Report::SortDirections[sort_column.report_sort]
        Map.new(order_column: sort_column_name, order_direction: sort_direction)
      end
    end

    def arel_includes
      self.report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.includes if column_info.respond_to? :includes
        }.compact
    end

    def arel_joins
      self.report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.joins if column_info.respond_to? :joins
        }.compact
    end

    def extra_scopes
      self.report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.extra_scopes if column_info.respond_to? :extra_scopes
        }.flatten.compact
    end

    def extra_filters
      self.report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.where if column_info.respond_to? :where
        }.flatten.compact
    end

    def groups
      self.report_columns.map{|column|
        column_info = self.column_options_for(column.column_name)
        column_info.group if column_info.respond_to? :group
        }.flatten.compact
    end

    def report_filter_params
      Hash[*self.report_filters.map{|filter| filter.filter_match_params}.flatten].
        merge(order: self.sorter)
    end

    def select_clauses
      @selects = []
      self.report_columns.each do |report_column|
        column_option = self.column_options_for(report_column.column_name)
        @selects.push column_option.custom_select if column_option.respond_to? :custom_select
      end
      self.report_filters.each do |report_filter|
        column_option = self.column_options_for(report_filter.filter_name)
        @selects.push column_option.custom_select if column_option.respond_to? :custom_select
      end
      @selects
    end


    def filter_options_for(filter_name)
      self.resource_class::REPORT_FILTER_OPTIONS.detect{|filter| filter.param == filter_name}
    end

    def column_options_for(column_name)
      if self.resource_class::REPORT_COLUMN_OPTIONS.has_key? column_name.to_sym
        self.resource_class::REPORT_COLUMN_OPTIONS[column_name.to_sym]
      else
        column_name = column_name.to_s.split('_')[0..-2].join('_')
        if self.resource_class::REPORT_COLUMN_OPTIONS.has_key? column_name.to_sym
          self.resource_class::REPORT_COLUMN_OPTIONS[column_name.to_sym]
        end
      end
    end

    def filter_kind(filter_name)
      self.filter_options_for(filter_name).kind
    end

    def date_filter_names
      self.resource_class::REPORT_FILTER_OPTIONS.select{|filter| 'date_filter' == filter.kind}.map{|filter| filter.param}
    end

    def available_filters
      self.available_email_filters.reject{|name| self.date_filter_names.include? name}
    end

    def available_filter_options
      self.available_filters.map{|id| [self.filter_options_for(id).label,id]}
    end

    def available_email_filters
      self.resource_class::REPORT_DEFINITION_OPTIONS.reject{|name| (self.report_filters.pluck(:filter_name)).include? name}
    end

    def collection_for(filter_name)
      self.resource_class::REPORT_FILTER_OPTIONS.detect{|filter| filter.param == filter_name}.collection
    end

    def custom_filters
      self.resource_class::REPORT_FILTER_OPTIONS.select{|filter| self.report_filters.pluck(:filter_name).exclude? filter.param}
    end

    def available_columns
      self.resource_class::REPORT_COLUMN_OPTIONS.keys.reject{|column| self.report_columns.pluck(:column_name).include? column.to_s}
    end

    def sortable?(column)
      !!(self.column_options_for(column.column_name).respond_to? :order_sql)
    end

    def sharing_scope_pretty
      (self.sharing_scope.try :name ) || 'Everyone'
    end

    def resource_type_pretty
      self.resource_class.prettify_name.pluralize
    end

    def get_filter_class(params)
      filter_option = self.resource_class::REPORT_FILTER_OPTIONS.detect{|filter| filter.param == params[:filter_name]}
      "ClarkKent::Report#{filter_option.kind.camelcase}".constantize
    end

    def summary_row_values(rows)
      self.report_columns.each_with_index.map do |report_column,index|
        report_column.calculate_summary(rows.map{|row| row[index]})
      end
    end

    def summary_row(rows)
      row_array = self.report_columns.map do |report_column|
        [report_column.column_name,report_column.calculate_summary(rows.map{|row| row.send(report_column.column_name)})]
      end
      Map.new(row_array.to_h)
    end

    def summary_row?
      @summary_row_presence ||= self.report_columns.to_a.any?{|c| c.summary_method.present? }
    end

    def headers
      the_headers = self.report_columns.sorted.pluck(:column_name)

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

  end
end
