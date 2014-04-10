require 'spec_helper'

describe 'Games can be created from schedulers', type: :feature do
  let(:klass) { described_class.to_s }
  let(:scheduler) do
    create(klass.underscore.to_sym, :with_sampled_profiles)
  end

  before do
    sign_in
  end

  shared_examples 'a scheduler when creating a game' do
    describe 'when trying to make a game that already exists' do
      let!(:game) do
        create(:game, simulator_instance: scheduler.simulator_instance,
                      name: scheduler.name)
      end
      it 'alerts the user' do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Create Game to Match'
        page.should have_content 'A game with that name already exists.'
        Game.count.should == 1
      end
    end
  end

  shared_examples 'a game scheduler when creating a game' do
    describe 'creating a game from a scheduler' do
      it 'creates a game that matches the scheduler' do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Create Game to Match'
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
        page.should have_content json_representation(
          scheduler.scheduling_requirements.first.profile)
      end
    end
  end

  shared_examples 'a deviation scheduler when creating a game' do
    describe 'creating a game from a scheduler' do
      let!(:profile) do
        create(:profile, :with_observations,
               simulator_instance: scheduler.simulator_instance,
               assignment: 'All: 1 A, 1 DeviousStrategy')
      end
      before do
        scheduler.simulator.add_strategy('All', 'DeviousStrategy')
        scheduler.add_deviating_strategy('All', 'DeviousStrategy')
        scheduler.reload
      end
      it 'creates a game that matches the scheduler' do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Create Game to Match'
        scheduler.roles.each do |role|
          page.should have_content role.name
          role.strategies.each do |strategy|
            page.should have_content strategy
          end
          role.deviating_strategies.each do |strategy|
            page.should have_content strategy
          end
        end
        page.should have_content "Name: #{scheduler.name}"
        page.should have_content "Size: #{scheduler.size}"
        scheduler.simulator_instance.configuration.each do |key, value|
          page.should have_content "#{key.humanize}: #{value}"
        end
        click_on 'Download JSON'
        page.should have_content json_representation(
          scheduler.scheduling_requirements.first.profile)
        page.should have_content json_representation(profile)
      end
    end
  end

  [GameScheduler, HierarchicalScheduler, DprScheduler].each do |s_class|
    describe s_class do
      it_behaves_like 'a game scheduler when creating a game'
      it_behaves_like 'a scheduler when creating a game'
    end
  end

  DEVIATION_SCHEDULER_CLASSES.each do |s_class|
    describe s_class do
      it_behaves_like 'a deviation scheduler when creating a game'
      it_behaves_like 'a scheduler when creating a game'
    end
  end

  describe GenericScheduler do
    it_behaves_like 'a scheduler when creating a game'

    let(:scheduler) { create(:generic_scheduler) }
    let!(:profile) do
      create(:profile, :with_observations,
             simulator_instance: scheduler.simulator_instance,
             assignment: 'All: 1 A, 1 B')
    end

    describe 'creating a game from a scheduler' do
      before do
        scheduler.simulator.add_strategy('All', 'A')
        scheduler.simulator.add_strategy('All', 'B')
        scheduler.add_role('All', 2)
        scheduler.add_profile('All: 1 A, 1 B')
        scheduler.reload
      end

      it 'adds all the profiles on the scheduler by adding the strategies' do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Create Game to Match'
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
        page.should have_content json_representation(profile)
      end
    end
  end
end

def json_representation(profile)
  profile.reload
  "{\"id\":#{profile.id},\"observations_count\":" \
    "#{profile.observations_count},\"symmetry_groups\":[" +
    profile.symmetry_groups.map do |s|
      "{\"id\":#{s.id},\"role\":\"#{s.role}\",\"strategy\":\"#{s.strategy}\"" \
      ",\"count\":#{s.count},\"payoff\":100,\"payoff_sd\":null}"
    end.join(',') + ']}'
end
