module ClarkKent
	module Reportable
	  extend ActiveSupport::Concern

	  module ClassMethods

	    def chain_up(query, params)
	      params.each do |key,val|
	        arel_method_name = self.arel_method_for(key)
	        if arel_method_name.present? and self.respond_to? arel_method_name and val.present?
	          query = self.send(arel_method_name, query, key, val)
	        end
	      end

	      query
	    end

	    def required_date_params
	    	self::REPORT_FILTER_OPTIONS.select{|rfo| rfo.in_required_date_group}.map{|rfo| rfo.filter_params}.flatten.map(&:to_sym)
	    end

	    def validate_params(params,report)
	    	if required_date_params.any?
	    		missing_params = required_date_params - params.select{|k,v| v.present? }.symbolize_keys.keys
	    		# a bit clunky, it only requires any 2 date filters. It would be better to require at least one pair of before/after filters
	    		if missing_params.length > (required_date_params.length - 2)
			    	raise ClarkKent::ReportFilterError.new("At least one date range is required.")
			    end
			  end
	    end

		  def report(params,report,count = false)
		  	@selects = []
		  	@includes = []
		  	@joins = []
		  	@extra_scopes = []
		  	@extra_filters = []
		  	@groups = []
		  	if 'ClarkKent::ReportEmail' == report.class.name
		  		@report_email = report
		  		report = @report_email.report
		  	end
		  	if count == false
					report.select_clauses.each do |select_clause|
						@selects.push select_clause
				  end
				end
		    report.arel_includes.each do |arel_include|
		    	@includes.push arel_include
		    end
		    report.arel_joins.each do |arel_join|
		    	@joins.push arel_join
		    end
		    report.extra_scopes.each do |extra_scope|
		    	@extra_scopes.push extra_scope
		    end
		    report.extra_filters.each do |extra_filter|
		    	@extra_filters.push extra_filter
		    end
		    report.groups.each do |grouper|
		    	@groups.push grouper
		    end
		    query = self.all
		    if @report_email and @report_email.is_a? ClarkKent::ReportEmail
					params = @report_email.report_filter_params.symbolize_keys!.merge(params.symbolize_keys)
		    else
					params = report.report_filter_params.symbolize_keys!.merge(params.symbolize_keys)
				end
		  	validate_params(params, report)
		    params.each do |param_type,param_value|
		      if param_value.present?
	          arel_method_name = self.arel_method_for(param_type)
		        if arel_method_name.present?
		          query = self.send(arel_method_name, query, param_type, param_value)
		          report_column_options = report.column_options_for(param_type)
		          if(report_column_options.respond_to? :joins) && (@joins.exclude? report_column_options.joins)
		          	@joins.push report_column_options.joins
		          end
							if(report_column_options.respond_to? :includes) && (@includes.exclude? report_column_options.includes)
								@includes.push report_column_options.includes
		          end
		          if (count == false) && (report_column_options.respond_to? :custom_select) && (@selects.exclude? report_column_options.custom_select)
		          	@selects.push report_column_options.custom_select
		          end
		        end
		      end
		    end
		    if @selects.any?
		    	query = query.select("DISTINCT " + self.column_names.map{|cn| self.table_name + '.' + cn}.join(', '))
		    	@selects.uniq.each do |selectable|
			    	query = query.select(selectable)
			    end
			  end
	    	@includes.uniq.each do |includeable|
		    	query = query.includes(includeable)
		    end if @includes.any?
	    	@extra_scopes.uniq.each do |extra_scope|
		    	query = query.send(extra_scope)
		    end if @extra_scopes.any?
	    	@extra_filters.uniq.each do |extra_filter|
		    	query = query.where(extra_filter)
		    end if @extra_filters.any?
	    	@joins.uniq.each do |joinable|
		    	query = query.joins(joinable).uniq
		    end if @joins.any?
	    	@groups.uniq.each do |grouper|
		    	query = query.group(grouper)
		    end if @groups.any?

		    if count == true
		    	return query.count
				else
					return query
				end

		  end

		  def arel_method_for(param_type)
		    method_name = self::AREL_METHODS[param_type.to_s]
		    method_name ||= "#{param_type}_arel" if self.respond_to? "#{param_type}_arel"
		    method_name
		  end

		  def simple_equality_arel(query, field_name, match_value)
		    query.
		    where(field_name.to_sym => match_value)
		  end

		  def before_date_arel(query, field_name, match_value)
		  	query.
		  	where("#{self.table_name}.#{field_name.to_s.sub(/_until/,'')} <= :date_limit", date_limit: match_value)
		  end

		  def after_date_arel(query, field_name, match_value)
		  	query.
		  	where("#{self.table_name}.#{field_name.to_s.sub(/_from/,'')} >= :date_limit", date_limit: match_value)
		  end

		  def above_number_arel(query, field_name, match_value)
		  	query.
		  	where("#{self.table_name}.#{field_name.to_s.sub(/_above/,'')} >= :lower_limit", lower_limit: match_value)
		  end

		  def below_number_arel(query, field_name, match_value)
		  	query.
		  	where("#{self.table_name}.#{field_name.to_s.sub(/_below/,'')} <= :upper_limit", upper_limit: match_value)
		  end

		  def order_arel(query, field_name, match_value)
		  	if match_value.is_a? ClarkKent::ReportSort
			  	order_column = match_value.order_column
			  	order_direction = match_value.order_direction
			  else
			  	order_column, order_direction = match_value.split('-')
			  end
				column_info = self::REPORT_COLUMN_OPTIONS[order_column.to_sym]
				if column_info.respond_to? :order_sql
				  order_sql = column_info.order_sql
			  	order_sql = "#{order_sql} #{order_direction}"
			  	query = query.order(order_sql)
			  	if column_info.respond_to? :includes
			  		order_includes = column_info.includes
		  			query = query.includes(order_includes).references(order_includes)
		  		end
		  		query
			  else
			  	query
			  end
		  end

		end
	end
end