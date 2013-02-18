class ApplicationController < ActionController::Base
  append_view_path '.'

  def index
    render :template => 'index'
  end

  def send_mail
    ContactMailer.new_message(params[:email], params[:message], params[:attachment]).deliver
    redirect_to '/', :notice => 'Email sent successfully, please check letter_opener_web inbox.'
  end
end

class ContactMailer < ActionMailer::Base
  append_view_path File.dirname(__FILE__)

  default :to            => 'admin@letter_opener_web.com',
          :from          => 'no-reply@letter_opener_web.com',
          :template_path => '.'

  def new_message(from, message, attachment)
    @from, @message = from, message
    if attachment.present?
      attachments[attachment.original_filename] = attachment.tempfile.read
    end
    mail(:subject => 'Testing letter_opener_web', :template_name => 'new_message')
  end
end
