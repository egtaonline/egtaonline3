require 'spec_helper'

describe ProfileAssociator do
  describe '#associate' do
    it 'spawns ProfileMaker jobs for each assignment in the profile space' do
      Scheduler.stub(:find).with(1).and_return(double(
        profile_space: ["A: 2 S1; B: 1 S2", "A: 1 S1, 1 S3; B: 1 S2"],
        simulator_instance_id: 1))
      ProfileMaker.should_receive(:perform_async).with(1, "A: 2 S1; B: 1 S2")
      ProfileMaker.should_receive(:perform_async).with(
        1, "A: 1 S1, 1 S3; B: 1 S2")
      subject.perform(1)
    end


    it 'destroys scheduling requirements that are outside the space' do
      profile1 = FactoryGirl.create(:profile, assignment: 'A: 2 S3; B: 1 S2')
      profile2 = FactoryGirl.create(:profile, assignment: 'A: 2 S1; B: 1 S2',
        simulator_instance: profile1.simulator_instance)
      scheduler = FactoryGirl.create(:game_scheduler,
        simulator_instance: profile2.simulator_instance, size: 3)
      ProfileMaker.stub(:perform_async)
      scheduler.add_role('A', 2)
      scheduler.add_role('B', 1)
      scheduler.add_strategy('A', 'S1')
      scheduler.add_strategy('B', 'S2')
      ProfileMaker.stub(:perform_async)
      profile1.scheduling_requirements.create!(scheduler: scheduler, count: 10)
      profile2.scheduling_requirements.create!(scheduler: scheduler, count: 10)
      subject.perform(scheduler.id)
      SchedulingRequirement.count.should == 1
      SchedulingRequirement.last.profile_id.should == profile2.id
    end

    it 'destroys scheduling requirements that have a different simulator_instance_id' do
      profile1 = FactoryGirl.create(:profile, assignment: 'A: 2 S1; B: 1 S2')
      profile2 = FactoryGirl.create(:profile, assignment: 'A: 2 S1; B: 1 S2')
      scheduler = FactoryGirl.create(:game_scheduler,
        simulator_instance: profile2.simulator_instance, size: 3)
      ProfileMaker.stub(:perform_async)
      scheduler.add_role('A', 2)
      scheduler.add_role('B', 1)
      scheduler.add_strategy('A', 'S1')
      scheduler.add_strategy('B', 'S2')
      profile1.scheduling_requirements.create!(scheduler: scheduler, count: 10)
      profile2.scheduling_requirements.create!(scheduler: scheduler, count: 10)
      subject.perform(scheduler.id)
      SchedulingRequirement.count.should == 1
      SchedulingRequirement.last.profile_id.should == profile2.id
    end
  end
end