require 'spec_helper'

describe AdminMailer do
  describe '#user_waiting_for_approval' do
    let(:user) { FactoryGirl.build(:user, email: 'fake@example.com') }
    let!(:admin) { create(:admin) }
    let(:mail) { AdminMailer.user_waiting_for_approval(user) }

    it 'sends user password reset url' do
      mail.subject.should eq('User requires approval')
      mail.to.should eq([admin.email])
      mail.from.should eq(%w(egtaonline.eecs.umich.edu))
    end

    it 'renders the body' do
      mail.body.encoded.should match("#{user.email} is awaiting approval.")
    end
  end
end
