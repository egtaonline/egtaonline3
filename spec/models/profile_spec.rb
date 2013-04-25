require 'spec_helper'

describe Profile do
  describe 'creation events' do
    it 'creates the necessary symmetry groups on creation' do
      simulator_instance = FactoryGirl.create(:simulator_instance)
      simulator_instance.profiles.create!(assignment: 'A: 2 S1, 1 S2; B: 3 S3')
      profile = Profile.last
      SymmetryGroup.count.should == 3
      SymmetryGroup.where(role: 'A', strategy: 'S1', count: 2, profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'A', strategy: 'S2', count: 1, profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'B', strategy: 'S3', count: 3, profile_id: profile.id).count.should == 1
    end
  end
  
  it 'sets the size correctly' do
    simulator_instance = FactoryGirl.create(:simulator_instance)
    simulator_instance.profiles.create!(assignment: 'A: 2 S1, 1 S2; B: 3 S3')
    Profile.last.size.should == 6
  end
end
