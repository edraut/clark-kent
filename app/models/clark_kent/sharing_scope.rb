module ClarkKent
  class SharingScope

    attr_accessor :parent

    def initialize(record, parent)
      @record = record
      @parent = parent
    end

    def dom_id
      str = parent.type
      str += "_#{@record.id}" if @record.respond_to? :id
      str += "_reports"
    end

    def human_name
      if @record.respond_to? :name
        @record.name
      else
        @record
      end
    end

    def reports
      if 'Everyone' == @record
        ClarkKent::Report.shared
      else
        @record.clark_kent_reports
      end
    end

  end
end