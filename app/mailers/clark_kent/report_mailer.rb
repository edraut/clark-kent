module ClarkKent
  class ReportMailer < ActionMailer::Base
  	default from: 'reservations@invitedhome.com'

  	def report_run(report_id, user_id, report_download_url)
  		@report = Report.find(report_id)
  		@user = User.find(user_id)
  		@recipient_email = @user.email
  		@report_download_url = report_download_url
  		@subject = "Your report #{@report.name} is ready"
  		mail(to: @recipient_email, subject: @subject)
  	end

  end
end