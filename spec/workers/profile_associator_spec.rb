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
      Scheduler.stub(:find).with(1).and_return(double(
        profile_space: ["A: 2 S1; B: 1 S2"],
        simulator_instance_id: profile1.simulator_instance.id))
      profile1.scheduling_requirements.create!(scheduler_id: 1, count: 10)
      profile2.scheduling_requirements.create!(scheduler_id: 1, count: 10)
      ProfileMaker.stub(:perform_async)
      subject.perform(1)
      SchedulingRequirement.count.should == 1
      SchedulingRequirement.last.profile_id.should == profile2.id
    end

    it 'destroys scheduling requirements that have a different simulator_instance_id' do
      profile1 = FactoryGirl.create(:profile, assignment: 'A: 2 S1; B: 1 S2')
      profile2 = FactoryGirl.create(:profile, assignment: 'A: 2 S1; B: 1 S2')
      Scheduler.stub(:find).with(1).and_return(double(
        profile_space: ["A: 2 S1; B: 1 S2"],
        simulator_instance_id: profile2.simulator_instance.id))
      profile1.scheduling_requirements.create!(scheduler_id: 1, count: 10)
      profile2.scheduling_requirements.create!(scheduler_id: 1, count: 10)
      ProfileMaker.stub(:perform_async)
      subject.perform(1)
      SchedulingRequirement.count.should == 1
      SchedulingRequirement.last.profile_id.should == profile2.id
    end
  end
end