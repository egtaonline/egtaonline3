require 'spec_helper'

feature 'user authentication:' do
  scenario 'a user tries to sign up' do
    admin = FactoryGirl.create(:admin)
    visit '/users/sign_up'
    fill_in 'Email', with: 'new_user@example.com'
    fill_in 'Password', with: 'fake-pass'
    fill_in 'Password confirmation', with: 'fake-pass'
    click_button 'Sign up'
    page.should have_content 'The admin has been emailed to verify your access.'
    last_email.to.should include(admin.email)
  end

  scenario 'an invalid signup does not email the admin for approval' do
    admin = FactoryGirl.create(:admin)
    visit '/users/sign_up'
    fill_in 'Email', with: 'new_user@example.com'
    fill_in 'Password', with: 'fake-pass'
    fill_in 'Password confirmation', with: 'fake-pass2'
    click_button 'Sign up'
    page.should have_content "Password confirmation doesn't match Password"
    last_email.should == nil
  end

  scenario 'an unconfirmed user tries to sign in' do
    user = FactoryGirl.create(:user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'fake-password'
    click_button 'Sign in'
    page.should have_content 'Your account has not been verified by the admin.'
  end

  scenario 'a confirmed user tries to sign in' do
    user = FactoryGirl.create(:approved_user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
    page.should have_content 'Signed in successfully.'
    visit '/simulators'
    current_path.should == '/simulators'
  end

  scenario 'a signed in user tries to sign out' do
    user = FactoryGirl.create(:approved_user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
    click_on 'Sign out'
    current_path.should == '/'
  end
end