module SessionHelpers
  def sign_in
    user = FactoryGirl.create(:approved_user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  def fill_in_with_hash(fill_in_hash)
    fill_in_hash.each { |key, value| fill_in key, with: value }
  end
end