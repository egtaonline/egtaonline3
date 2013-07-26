require 'spec_helper'

describe Profile do
  let!(:profile){ FactoryGirl.create(:profile,
    assignment: 'A: 2 S1, 1 S2; B: 3 S3') }
  describe 'creation events' do
    it 'creates the necessary symmetry groups on creation' do
      SymmetryGroup.where(profile_id: profile.id).count.should == 3
      profile.role_configuration['A'].should == 3
      SymmetryGroup.where(role: 'A', strategy: 'S1', count: 2,
        profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'A', strategy: 'S2', count: 1,
        profile_id: profile.id).count.should == 1
      SymmetryGroup.where(role: 'B', strategy: 'S3', count: 3,
        profile_id: profile.id).count.should == 1
      profile.role_configuration['B'].should == 3
    end

    it 'sets the size correctly' do
      profile.size.should == 6
    end

    it 'triggers ProfileScheduler' do
      ProfileScheduler.should_receive(:perform_in)
      FactoryGirl.create(:profile)
    end
  end

  describe '#scheduled?' do
    context 'when an active simulation exists' do
      let!(:simulation){ FactoryGirl.create(:simulation, state: 'queued',
        profile: profile) }

      it { profile.scheduled?.should == true }
    end

    context 'when no active simulation for the profile exists' do
      it { profile.scheduled?.should == false }
    end
  end

  describe '#profile_matches_simulator' do
    let!(:simulator){ FactoryGirl.create(:simulator) }
    let!(:simulator_instance) do
      FactoryGirl.create(:simulator_instance, simulator: simulator)
    end
    it 'passes only when all the strategies/roles are on the simulator' do
      simulator.add_strategy('All', 'A')
      profile = FactoryGirl.build(:profile,
        simulator_instance: simulator_instance, assignment: 'All: 2 A')
      profile.valid?.should == true
    end

    it 'fails when the strategy is not present on the simulator' do
      profile = FactoryGirl.build(:profile,
        simulator_instance: simulator_instance, assignment: 'All: 2 A')
      profile.valid?.should == false
    end
  end

  describe '#try_scheduling' do
    it 'calls the ProfileScheduler' do
      ProfileScheduler.should_receive(:perform_in).with(5.minutes, profile.id)
      profile.try_scheduling
    end
  end

  describe '#scheduled?' do
    it 'returns true if the profile has scheduled simulations' do
      FactoryGirl.create(:simulation, profile: profile)
      profile.reload.scheduled?.should == true
    end

    it 'returns false is the profile does not have scheduled simulations' do
      profile.scheduled?.should == false
    end
  end

  describe '#add_observation' do
    let(:data){ double('data') }
    it 'delegates to Observation to create an observation with its id' do
      Observation.should_receive(:create_from_validated_data).with(
        profile, data)
      profile.add_observation(data)
    end
  end
end
