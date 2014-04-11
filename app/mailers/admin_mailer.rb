class AdminMailer < ActionMailer::Base
  default from: 'egtaonline.eecs.umich.edu'

  def user_waiting_for_approval(user)
    email = User.where(admin: true).pluck(:email).first
    if email
      @user = user
      mail to: email, subject: 'User requires approval'
    end
  end
end