class AdminMailer < ActionMailer::Base
  default from: 'egtaonline.eecs.umich.edu'

  def user_waiting_for_approval(user)
    @user = user
    mail to: 'wellman@umich.edu', subject: 'User requires approval'
  end
end
