require 'spec_helper'

describe ProfileScheduler do
  describe '#schedule' do
    context 'profile is not scheduled' do
      let!(:profile){ FactoryGirl.create(:profile) }

      # Needs to be tested with timing

      # context 'profile scheduling requirements exist' do
      #   it "it requests a simulation from the scheduler with the largest requirement" do
      #     scheduling_requirement = FactoryGirl.create(:scheduling_requirement, profile: profile, count: 1)
      #     scheduling_requirement2 = FactoryGirl.create(:scheduling_requirement, profile: profile, count: 5)
      #     subject.perform(profile.id)
      #     Simulation.last.size.should == 5
      #   end
      # end
    end
  end
end