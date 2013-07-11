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
end