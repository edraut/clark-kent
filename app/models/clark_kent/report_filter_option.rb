module ClarkKent
	class ReportFilterOption
	  include Cloneable

		attr_accessor :param, :label, :collection, :kind, :select
		def initialize(params)
			self.param = params[:param] if params[:param].present?
			self.label = params[:label] if params[:label].present?
			self.collection = params[:collection] if params[:collection].present?
			self.kind = params[:kind] if params[:kind].present?
			self.select = params[:select] if params[:select].present?
		end

		def label
			@label || @param
		end
	end
end