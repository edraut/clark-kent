module ClarkKent
  class UserEmailValidator < ActiveModel::Validator
    def validate(record)
      record.errors[:email] << "Couldn't find a user with that email address" unless record.user.present?
    end
  end
end