class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable, :token_authenticatable

  after_create :send_admin_mail
  before_save :ensure_authentication_token

  def send_admin_mail
    if !admin?
      AdminMailer.user_waiting_for_approval(self).deliver
    end
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end
end
