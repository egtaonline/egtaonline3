require 'spec_helper'

describe GenericScheduler do
  let(:scheduler){ FactoryGirl.create(:generic_scheduler) }

  describe '#add_profile' do
    before do
      scheduler.simulator.add_strategy('All', 'A')
    end
    context 'when the scheduler lacks the necessary roles' do
      it 'returns a profile with an error expressing as much' do
        profile = scheduler.add_profile('All: 2 A')
        profile.errors.messages.empty?.should == false
      end
    end
    context 'when the scheduler has the necessary roles' do
      before do
        scheduler.add_role('All', 2)
      end
      context 'when the profile does not already exist' do
        before do
          scheduler.add_profile("All: 2 A")
        end
        it { Profile.where(
          simulator_instance_id: scheduler.simulator_instance_id,
          assignment: "All: 2 A").count.should == 1 }
        it { scheduler.reload.scheduling_requirements.count.should == 1 }
      end

      context 'when the profile already exists' do
        before do
          @profile = FactoryGirl.create(:profile,
            simulator_instance_id: scheduler.simulator_instance_id,
            assignment: "All: 2 A")
          scheduler.add_profile("All: 2 A")
        end

        it { Profile.where(
          simulator_instance_id: scheduler.simulator_instance_id,
          assignment: "All: 2 A").count.should == 1 }
        it { scheduler.scheduling_requirements.first.profile.should == @profile}
      end
    end
  end

  describe '#remove_profile_by_id' do
    let!(:profile) do
      FactoryGirl.create(:profile,
        simulator_instance: scheduler.simulator_instance,
        assignment: 'R1: 1 B; R2: 1 D')
    end
    before do
      scheduler.simulator.add_strategy('R1', 'A')
      scheduler.simulator.add_strategy('R1', 'B')
      scheduler.simulator.add_strategy('R2', 'C')
      scheduler.simulator.add_strategy('R2', 'D')
      scheduler.add_role('R1', 1)
      scheduler.add_role('R2', 1)
      scheduler.add_profile('R1: 1 A; R2: 1 C')
      scheduler.add_profile('R1: 1 A; R2: 1 D')
      scheduler.add_profile('R1: 1 B; R2: 1 D')
    end

    it 'removes the scheduling requirement and relevant strategies' do
      scheduler.remove_profile_by_id(profile.id)
      scheduler.reload
      scheduler.scheduling_requirements.find_by(
        profile_id: profile.id).should == nil
      scheduler.roles.find_by(name: 'R1').strategies.should == ['A']
      scheduler.roles.find_by(name: 'R2').strategies.should == ['C', 'D']
    end
  end
end