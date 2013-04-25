require 'spec_helper'

describe ProfileAssociator do
  describe '#associate' do
    let(:scheduler){ FactoryGirl.create(:game_scheduler) }
    
    it 'spawns ProfileMaker jobs for each assignment in the profile space' do
      scheduler.stub(:profile_space).and_return(["A: 2 S1; B: 1 S2", "A: 1 S1, 1 S3; B: 1 S2"])
      pm = double("ProfileMaker")
      ProfileMaker.stub(:new).and_return(pm)
      pm.should_receive(:find_or_create).with(scheduler, "A: 2 S1; B: 1 S2")
      pm.should_receive(:find_or_create).with(scheduler, "A: 1 S1, 1 S3; B: 1 S2")      
      subject.associate(scheduler)
    end
    
    it 'destroys scheduling requirements that are outside the space' do
      scheduler.stub(:profile_space).and_return(["A: 2 S1; B: 1 S2"])
      profile1 = scheduler.simulator_instance.profiles.create!(assignment: 'A: 2 S3; B: 1 S2')
      profile2 = scheduler.simulator_instance.profiles.create!(assignment: 'A: 2 S1; B: 1 S2')
      profile1.scheduling_requirements.create!(scheduler_id: scheduler.id, count: 10)
      profile2.scheduling_requirements.create!(scheduler_id: scheduler.id, count: 10)
      ProfileMaker.stub(:new).and_return(double(find_or_create: nil))
      subject.associate(scheduler)
      SchedulingRequirement.count.should == 1
      SchedulingRequirement.last.profile_id.should == profile2.id
    end
  end
end