module ClarkKent
	class UserReportEmail < ActiveRecord::Base
    include ClarkKent::Cloneable

		belongs_to :user, class_name: ClarkKent.user_class_name
		belongs_to :report_email

	  validates_with UserEmailValidator

		def email=(address)
			self.user = ClarkKent.user_class.where("lower(#{ClarkKent.user_class_name.underscore.pluralize}.email) = lower(:email)",email: address).first
			self.errors.add(:email, "Couldn't find a user with that email addres") unless self.user.present?
		end

		def email
			self.user.try :email
		end
	end
end