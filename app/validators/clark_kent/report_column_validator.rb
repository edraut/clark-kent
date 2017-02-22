module ClarkKent
  class ReportColumnValidator < ActiveModel::Validator
    def validate(record)
      if record.report_sort.present?
        record.errors[:report_sort] << "This column is not sortable." unless record.sortable?
      end
    end
  end
end