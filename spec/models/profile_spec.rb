require 'spec_helper'

describe Profile do
  let(:profile){ FactoryGirl.create(:profile,
    assignment: 'A: 2 S1, 1 S2; B: 3 S3') }
  describe 'creation events' do
    it 'creates the necessary symmetry groups on creation' do
      SymmetryGroup.where(profile_id: profile.id).count.should == 3
      SymmetryGroup.where(role: 'A', strategy: 'S1', count: 2,
        profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'A', strategy: 'S2', count: 1,
        profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'B', strategy: 'S3', count: 3,
        profile_id: profile.id).count.should == 1
    end

    it 'sets the size correctly' do
      profile.size.should == 6
    end
  end

  it 'triggers ProfileScheduler' do
    ProfileScheduler.should_receive(:perform_in)
    FactoryGirl.create(:profile)
  end

  describe '#scheduled?' do
    context 'when an active simulation exists' do
      let!(:simulation){ FactoryGirl.create(:simulation, state: 'queued', profile: profile) }

      it { profile.scheduled?.should == true }
    end

    context 'when no active simulation for the profile exists' do
      it { profile.scheduled?.should == false }
    end
  end
end
