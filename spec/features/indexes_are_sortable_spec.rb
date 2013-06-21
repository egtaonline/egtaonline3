require 'spec_helper'

feature 'index pages are sortable' do
  background do
    sign_in
  end

  scenario 'when on the simulator index page' do
    simulator1 = FactoryGirl.create(:simulator, version: 'alpha')
    simulator2 = FactoryGirl.create(:simulator, version: 'beta')
    visit simulators_path
    click_on 'Version'
    within(:xpath, "//tbody/tr[1]/td[2]") do
      page.should have_content('alpha')
    end
    within(:xpath, "//tbody/tr[2]/td[2]") do
      page.should have_content('beta')
    end
    click_on 'Version'
    within(:xpath, "//tbody/tr[1]/td[2]") do
      page.should have_content('beta')
    end
    within(:xpath, "//tbody/tr[2]/td[2]") do
      page.should have_content('alpha')
    end
  end

  ['game_scheduler', 'deviation_scheduler', 'dpr_deviation_scheduler', 'dpr_scheduler',
   'generic_scheduler', 'hierarchical_deviation_scheduler', 'hierarchical_scheduler'].each do |scheduler|
    scenario 'some schedulers' do
      first_name, second_name = [FactoryGirl.create(scheduler.to_sym).simulator_fullname,
                                 FactoryGirl.create(scheduler.to_sym).simulator_fullname].sort

      visit "/#{scheduler}s"
      within(".main") do
        click_on 'Simulator'
      end
      within(:xpath, "//tbody/tr[1]/td[3]") do
        page.should have_content(first_name)
      end
      within(:xpath, "//tbody/tr[2]/td[3]") do
        page.should have_content(second_name)
      end
      within(".main") do
        click_on 'Simulator'
      end
      within(:xpath, "//tbody/tr[1]/td[3]") do
        page.should have_content(second_name)
      end
      within(:xpath, "//tbody/tr[2]/td[3]") do
        page.should have_content(first_name)
      end
    end
  end

  scenario 'some simulations' do
    simulation = FactoryGirl.create(:simulation, state: 'queued')
    simulation2 = FactoryGirl.create(:simulation, state: 'pending')
    visit simulations_path
    click_on 'State'
    within(:xpath, "//tbody/tr[1]/td[1]") do
      page.should have_content('pending')
    end
    within(:xpath, "//tbody/tr[2]/td[1]") do
      page.should have_content('queued')
    end
    click_on 'State'
    within(:xpath, "//tbody/tr[1]/td[1]") do
      page.should have_content('queued')
    end
    within(:xpath, "//tbody/tr[2]/td[1]") do
      page.should have_content('pending')
    end
  end
end