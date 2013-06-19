require 'spec_helper'

describe 'Games can be created from schedulers', type: :feature do
  before do
    sign_in
  end

  SCHEDULER_CLASSES.collect{ |klass| klass.to_s.underscore }.each do |scheduler_klass|
    context "when a game is created from a #{scheduler_klass}" do
      let(:scheduler){ FactoryGirl.create(scheduler_klass, :with_sampled_profiles) }

      before do
        visit "/#{scheduler_klass}s/#{scheduler.id}"
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
      end
    end
  end
end