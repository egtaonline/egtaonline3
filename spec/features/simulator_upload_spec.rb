require 'spec_helper'

feature 'users can upload new simulators:' do
  background do
    sign_in
    visit new_simulator_path
  end

  scenario 'with valid simulator' do
    fill_in 'Name', with: 'fake-sim'
    fill_in 'Version', with: '1.0'
    fill_in 'Email', with: 'test@example.com'
    attach_file 'Zipped Source', "#{Rails.root}/spec/support/data/fake-sim.zip"
    click_button 'Upload Simulator'
    page.should have_content 'Inspect Simulator'
    # configuration information
    page.should have_content 'Parm-integer:  60'
  end
end

feature 'users can update simulators with new programs' do
  scenario 'with valid simulator' do
    sign_in
    simulator = Simulator.create!(name: 'fake-sim', version: '1.0', email: 'test@example.com',
                                  source: File.new("#{Rails.root}/spec/support/data/fake-sim.zip"))
    simulator.configuration["parm-integer"] = 61
    simulator.save!
    visit edit_simulator_path(simulator)
    fill_in 'Email', with: 'test1@example.com'
    attach_file 'Zipped Source', "#{Rails.root}/spec/support/data/fake-sim.zip"
    click_button 'Update Simulator'
    page.should have_content 'Inspect Simulator'
    # configuration information
    page.should have_content 'Parm-integer:  60'
    page.should have_content 'Email:  test1@example.com'
  end
end