require 'spec_helper'

describe 'Games can be created from schedulers', type: :feature do
  before do
    sign_in
  end

  context "when a game is created from a scheduler" do
    let(:scheduler){ FactoryGirl.create(:game_scheduler, :with_sampled_profiles) }

    before do
      visit "/game_schedulers/#{scheduler.id}"
      click_on 'Create Game to Match'
    end

    it 'the game matches the scheduler' do
      scheduler.roles.each do |role|
        page.should have_content role.name
        role.strategies.each do |strategy|
          page.should have_content strategy
        end
      end
      page.should have_content "Name: #{scheduler.name}"
      page.should have_content "Size: #{scheduler.size}"
      scheduler.simulator_instance.configuration.each do |key, value|
        page.should have_content "#{key.humanize}: #{value}"
      end
      click_on 'Download JSON'
      page.should have_content json_representation(scheduler.scheduling_requirements.first.profile)
    end
  end
end

def json_representation(profile)
  "{\"id\":#{profile.id},\"symmetry_groups\":[#{profile.symmetry_groups.collect{ |s| "{\"id\":#{s.id},\"role\":\"#{s.role}\",\"strategy\":\"#{s.strategy}\",\"count\":#{s.count},\"payoff\":100,\"payoff_sd\":#{s.count > 1 ? 0 : 'null'}}" }.join(',')}]}"
end