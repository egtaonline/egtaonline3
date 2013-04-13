require 'spec_helper'

describe User do
  describe 'creation' do
    it 'emails the admin for approval' do
      user = FactoryGirl.build(:user)
      email = double('email')
      AdminMailer.should_receive(:user_waiting_for_approval).with(user).and_return(email)
      email.should_receive(:deliver)
      user.save
    end
  end
  
  describe '#active_for_authentication?' do
    it 'only returns true for approved users' do
      user = FactoryGirl.build(:user)
      user.active_for_authentication?.should == false
      user.approved = true
      user.active_for_authentication?.should == true
    end
  end
  
  describe '#inactive_message' do
    it 'returns the special message if the user is unapproved' do
      user = FactoryGirl.build(:user)
      user.inactive_message.should == :not_approved
    end
  end
end