require 'spec_helper'

feature 'some objects have index pages' do
  background do
    sign_in
  end

  scenario 'some simulators' do
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
      scheduler1 = FactoryGirl.create(scheduler.to_sym)
      scheduler2 = FactoryGirl.create(scheduler.to_sym)
      visit "/#{scheduler}s"
      within(".main") do
        click_on 'Simulator'
      end
      within(:xpath, "//tbody/tr[1]/td[3]") do
        page.should have_content(scheduler1.simulator_fullname)
      end
      within(:xpath, "//tbody/tr[2]/td[3]") do
        page.should have_content(scheduler2.simulator_fullname)
      end
      within(".main") do
        click_on 'Simulator'
      end
      within(:xpath, "//tbody/tr[1]/td[3]") do
        page.should have_content(scheduler2.simulator_fullname)
      end
      within(:xpath, "//tbody/tr[2]/td[3]") do
        page.should have_content(scheduler1.simulator_fullname)
      end
    end
  end
end