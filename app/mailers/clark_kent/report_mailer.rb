module ClarkKent
  class ReportMailer < ActionMailer::Base
  	default from: 'reservations@invitedhome.com'

  	def report_run(report_id, user_id, report_accessor)
  		@report = Report.find(report_id)
  		@user = ::User.find(user_id)
  		@recipient_email = @user.email
      if 'login_required' == ClarkKent.email_security
        @report_filename = report_accessor
      else
        @report_download_url = report_accessor
      end
  		@subject = "Your report #{@report.name} is ready"
  		mail(to: @recipient_email, subject: @subject)
  	end

    def report_error(report_id, user_id, error_message)
      @report = Report.find(report_id)
      @user = ::User.find(user_id)
      @recipient_email = @user.email
      @error_message = error_message
      @subject = "Your report #{@report.name} has a problem"
      mail(to: @recipient_email, subject: @subject)
    end
  end
end