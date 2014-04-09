require 'spec_helper'

describe "Admins can approve users" do
  describe 'when a non-admin' do
    before do
      sign_in
    end

    context 'attempts to view the users page' do
      it "redirects to root and informs that only admins can view the page" do
        visit "/users"
        page.should have_content('You must be an admin to visit that page.')
        current_path.should == '/'
      end
    end

    context 'attempts to update the approval of a user', type: :api do
      let(:user){ create(:user) }
      it "does not change the approval of the user" do
        put "/users/#{user.id}", user: { approved: true }
        user.reload.approved.should == false
      end
    end
  end

  describe 'when an admin' do
    before do
      user = create(:admin)
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    let!(:approved_user){ create(:approved_user) }
    let!(:unapproved_user){ create(:user) }
    context 'attempts to view the users page' do
      it "can see the email for unapproved users" do
        visit "/users"
        page.should have_content(unapproved_user.email)
        page.should_not have_content(approved_user.email)
      end
    end

    context 'attempts to update the approval of a user', type: :api do
      it 'updates the approval of the user and redirects to the index' do
        visit '/users'
        click_on 'Approve'
        unapproved_user.reload.approved.should == true
        page.should_not have_content(unapproved_user.email)
        current_path.should == '/users'
      end
    end
  end
end