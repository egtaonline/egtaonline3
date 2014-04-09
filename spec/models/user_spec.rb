require 'spec_helper'

describe User do
  describe 'creation' do
    it 'emails the admin for approval' do
      user = build(:user)
      email = double('email')
      AdminMailer.should_receive(:user_waiting_for_approval)
        .with(user).and_return(email)
      email.should_receive(:deliver)
      user.save
    end
  end

  describe '#active_for_authentication?' do
    it 'only returns true for approved users' do
      user = build(:user)
      expect(user.active_for_authentication?).to eq(false)
      user.approved = true
      expect(user.active_for_authentication?).to eq(true)
    end
  end

  describe '#inactive_message' do
    it 'returns the special message if the user is unapproved' do
      user = build(:user)
      expect(user.inactive_message).to eq(:not_approved)
    end
  end
end
