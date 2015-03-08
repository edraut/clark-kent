module ClarkKent
	class ReportResult
		include Enumerable

		def initialize(arel_query, params)
			@arel_query = arel_query
			@params = params
		end

		def paginated_query
			if @params.has_key? :page and @params.has_key? :per
				page = @params[:page] || 1
				@arel_query.offset((page.to_i - 1) * @params[:per]).limit(@params[:per])
			else
				@arel_query
			end
		end

		def current_page
			@params[:page]
		end

		def per_page
			@params[:per]
		end

		def query
			@arel_query
		end

		def total_count
			unless defined?(@total_count)
				results = results_for(@arel_query.to_sql)
				@total_count = results.num_tuples
			end

			@total_count
		end

		def rows
			results_for(paginated_query.to_sql)
		end

		def each(&block)
			rows.each(&block)
		end

		private

			def results_for(sql)
				Report.connection.raw_connection.exec(sql)
			end

	end
end