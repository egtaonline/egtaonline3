require 'spec_helper'

describe 'The flux proxy can be connected through the web page',
         type: :feature do
  before do
    sign_in
  end

  let(:uniqname) { 'Fake' }
  let(:password) { 'Also fake' }
  let(:verification_number) { 'More fake' }

  context 'when the proxy is not authenticated' do
    context 'when the authentication is successful' do
      it 'informs the user that authentication succeeded' do
        Backend.should_receive(:connected?).twice.and_return(false)
        visit '/'
        expect(page).to have_content(
          'Missing connection to Flux. ' \
          'Please authenticate with your Flux account to restore.')
        click_on 'Please authenticate with your Flux account to restore.'
        fill_in 'Uniqname', with: uniqname
        fill_in 'Password', with: password
        Backend.should_receive(:authenticate).with(
          'uniqname' => uniqname,
          'password' => password).and_return(true)
        Backend.should_receive(:connected?).and_return(true)
        click_on 'Connect to Flux'
        expect(page).to have_content('Successfully connected to Flux.')
        expect(page).to_not have_content(
          'Missing connection to Flux. ' \
          'Please authenticate with your Flux account to restore.')
      end
    end

    context 'when the authentication is unsuccessful' do
      before do
        Backend.should_receive(:authenticate).with(
          'uniqname' => uniqname, 'password' => password
          ).and_return(false)
        Backend.should_receive(:connected?).exactly(3).times.and_return(false)
        visit '/'
      end

      it 'informs the user that authentication failed' do
        expect(page).to have_content(
          'Missing connection to Flux. ' \
          'Please authenticate with your Flux account to restore.')
        click_on 'Please authenticate with your Flux account to restore.'
        fill_in 'Uniqname', with: uniqname
        fill_in 'Password', with: password
        click_on 'Connect to Flux'
        expect(page).to have_content('Failed to authenticate.')
      end
    end
  end
end
