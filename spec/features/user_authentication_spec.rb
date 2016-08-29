require 'spec_helper'

feature 'user authentication:' do
#  scenario 'a user tries to sign up' do
#    admin = create(:admin)
#    visit '/users/sign_up'
#    fill_in 'Email', with: 'new_user@example.com'
#    fill_in 'Password', with: 'fake-pass'
#    fill_in 'Password confirmation', with: 'fake-pass'
#    click_button 'Sign up'
#    expect(page)
#      .to have_content 'The admin has been emailed to verify your access.'
#    expect(last_email.to).to include(admin.email)
#  end

  scenario 'an invalid signup does not email the admin for approval' do
    create(:admin)
    visit '/users/sign_up'
    fill_in 'Email', with: 'new_user@example.com'
    fill_in 'Password', with: 'fake-pass'
    fill_in 'Password confirmation', with: 'fake-pass2'
    click_button 'Sign up'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(last_email.nil?).to be_true
  end

  scenario 'an unconfirmed user tries to sign in' do
    user = create(:user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'fake-password'
    click_button 'Sign in'
    expect(page)
      .to have_content 'Your account has not been verified by the admin.'
  end

  scenario 'a confirmed user tries to sign in' do
    user = create(:approved_user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
    expect(page).to have_content 'Signed in successfully.'
    visit '/simulators'
    expect(current_path).to eq('/simulators')
  end

  scenario 'a signed in user tries to sign out' do
    user = create(:approved_user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
    click_on 'Sign out'
    expect(current_path).to eq('/')
  end
end
