module ClarkKent
	class UserReportEmail < ActiveRecord::Base
		belongs_to :user
		belongs_to :report_email

		attr_accessible :email, :report_email_id

	  validates_with UserEmailValidator

		def email=(address)
			self.user = User.where("lower(users.email) = lower(:email)",email: address).first
			self.errors.add(:email, "Couldn't find a user with that email addres") unless self.user.present?
		end

		def email
			self.user.try :email
		end
	end
end