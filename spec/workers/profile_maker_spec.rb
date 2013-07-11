require 'spec_helper'

describe ProfileMaker do
  describe '#find_or_create' do
    let(:scheduler){ FactoryGirl.create(:game_scheduler) }

    before do
      simulator = scheduler.simulator
      simulator.add_strategy('B', 'S1')
      simulator.add_strategy('A', 'S2')
      simulator.add_strategy('A', 'S3')
    end

    it 'creates a profile with the required assignment when necessary' do
      subject.perform(scheduler.id, 'B: 2 S1; A: 1 S3, 1 S2')
      profile = Profile.last
      profile.simulator_instance_id.should == scheduler.simulator_instance_id
      profile.assignment.should == 'A: 1 S2, 1 S3; B: 2 S1'
    end

    it 'does not create a profile when the necessary profile exists' do
      profile = scheduler.simulator_instance.profiles.create!(
        assignment: 'A: 1 S2, 1 S3; B: 2 S1')
      subject.perform(scheduler.id, 'B: 2 S1; A: 1 S3, 1 S2')
      Profile.count.should == 1
    end

    it 'creates a scheduling requirement if necessary' do
      profile = scheduler.simulator_instance.profiles.create!(
        assignment: 'A: 1 S2, 1 S3; B: 2 S1')
      subject.perform(scheduler.id, 'B: 2 S1; A: 1 S3, 1 S2')
      scheduling_requirement = SchedulingRequirement.last
      scheduling_requirement.profile_id.should == profile.id
      scheduling_requirement.scheduler_id.should == scheduler.id
      scheduling_requirement.count.should ==
        scheduler.default_observation_requirement
    end

    it 'does not replace existing profiles' do
      profile = scheduler.simulator_instance.profiles.create!(
        assignment: 'A: 1 S2, 1 S3; B: 2 S1')
      profile.scheduling_requirements.create!(scheduler_id: scheduler.id,
        count: scheduler.default_observation_requirement)
      subject.perform(scheduler.id, 'B: 2 S1; A: 1 S3, 1 S2')
      Profile.count.should == 1
      SchedulingRequirement.count.should == 1
    end
  end
end