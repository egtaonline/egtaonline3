require 'spec_helper'

describe 'The flux proxy can be connected through the web page', type: :feature do
  before do
    sign_in
  end

  let(:uniqname){ 'Fake' }
  let(:password){ 'Also fake'}
  let(:verification_number){ 'More fake' }

  context 'when the proxy is not authenticated' do
    before do
      Backend.connected = false
    end

    context 'when the authentication is successful' do
      before do
        Backend.connection.should_receive(:authenticate).with({ "uniqname" => uniqname, "password" => password, "verification_number" => verification_number}).and_return(true)
        visit '/'
      end

      it 'informs the user that authentication succeeded' do
        page.should have_content('Missing connection to Flux. Please authenticate with your Flux account to restore.')
        click_on 'Please authenticate with your Flux account to restore.'
        fill_in 'Uniqname', with: uniqname
        fill_in 'Password', with: password
        fill_in 'Verification number', with: verification_number
        click_on 'Connect to Flux'
        page.should have_content('Successfully connected to Flux.')
        page.should_not have_content('Missing connection to Flux. Please authenticate with your Flux account to restore.')
      end
    end

    context 'when the authentication is unsuccessful' do
      before do
        Backend.connection.should_receive(:authenticate).with({ "uniqname" => uniqname, "password" => password, "verification_number" => verification_number}).and_return(false)
        visit '/'
      end

      it 'informs the user that authentication succeeded' do
        page.should have_content('Missing connection to Flux. Please authenticate with your Flux account to restore.')
        click_on 'Please authenticate with your Flux account to restore.'
        fill_in 'Uniqname', with: uniqname
        fill_in 'Password', with: password
        fill_in 'Verification number', with: verification_number
        click_on 'Connect to Flux'
        page.should have_content('Failed to authenticate.')
      end
    end
  end
end