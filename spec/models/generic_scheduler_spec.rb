require 'spec_helper'

describe GenericScheduler do
  let(:scheduler){ FactoryGirl.create(:generic_scheduler) }

  describe '#add_profile' do
    context 'when the profile does not already exist' do
      before do
        scheduler.add_profile("All: 2 A")
      end
      it { Profile.where(simulator_instance_id: scheduler.simulator_instance_id, assignment: "All: 2 A").count.should == 1 }
      it { scheduler.reload.scheduling_requirements.count.should == 1 }
    end

    context 'when the profile already exists' do
      before do
        @profile = FactoryGirl.create(:profile, simulator_instance_id: scheduler.simulator_instance_id, assignment: "All: 2 A")
        scheduler.add_profile("All: 2 A")
      end

      it { Profile.where(simulator_instance_id: scheduler.simulator_instance_id, assignment: "All: 2 A").count.should == 1 }
      it { scheduler.reload.scheduling_requirements.first.profile_id.should == @profile.id}
    end
  end
end