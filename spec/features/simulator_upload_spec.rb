require 'spec_helper'

describe 'Simulator upload functionality' do
  before :all do
    Simulator.set_callback(:validation, :before, :setup_simulator, if: :source_changed?)
  end

  after :all do
    Simulator.skip_callback(:validation, :before, :setup_simulator)
  end

  before do
    sign_in
  end

  describe 'users can upload new simulators:', type: :feature do
    it 'creates a new Simulator with valid simulator .zip' do
      visit new_simulator_path
      fill_in 'Name', with: 'fake_sim'
      fill_in 'Version', with: '1.0'
      fill_in 'Email', with: 'test@example.com'
      attach_file 'Zipped Source', "#{Rails.root}/spec/support/data/fake_sim.zip"
      Backend.should_receive(:prepare_simulator)
      click_button 'Upload Simulator'
      page.should have_content 'Inspect Simulator'
      # configuration information
      page.should have_content 'Parm-integer: 60'
    end
  end

  describe 'users can update simulators with new programs', type: :feature do
    it 'updates a Simulator with valid simulator' do
      Backend.should_receive(:prepare_simulator)
      simulator = Simulator.create!(name: 'fake_sim', version: '1.0', email: 'test@example.com',
                                    source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
      simulator.configuration["parm-integer"] = 61
      simulator.save!
      visit edit_simulator_path(simulator)
      fill_in 'Email', with: 'test1@example.com'
      attach_file 'Zipped Source', "#{Rails.root}/spec/support/data/fake_sim_copy.zip"
      Backend.should_receive(:prepare_simulator)
      click_button 'Update Simulator'
      page.should have_content 'Inspect Simulator'
      # configuration information
      page.should have_content "Parm-integer: 60"
      page.should have_content 'Email: test1@example.com'
    end
  end
end