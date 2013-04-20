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

  scenario 'some schedulers' do
    scheduler1 = FactoryGirl.create(:game_scheduler)
    scheduler2 = FactoryGirl.create(:game_scheduler)
    visit schedulers_path
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