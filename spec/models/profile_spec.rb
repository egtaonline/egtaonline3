require 'spec_helper'

describe Profile do
  let!(:profile) do
    create(:profile, assignment: 'A: 2 S1, 1 S2; B: 3 S3')
  end
  describe 'creation events' do
    it 'creates the necessary symmetry groups on creation' do
      expect(SymmetryGroup.where(profile_id: profile.id).count).to eq(3)
      expect(profile.role_configuration['A']).to eq(3)
      expect(SymmetryGroup.where(
        role: 'A', strategy: 'S1', count: 2, profile_id: profile.id).count)
          .to eq(1)
      expect(SymmetryGroup.where(
        role: 'A', strategy: 'S2', count: 1, profile_id: profile.id).count)
          .to eq(1)
      expect(SymmetryGroup.where(
        role: 'B', strategy: 'S3', count: 3, profile_id: profile.id).count)
          .to eq(1)
      expect(profile.role_configuration['B']).to eq(3)
    end

    it 'sets the size correctly' do
      expect(profile.size).to eq(6)
    end
  end

  describe '#scheduled?' do
    context 'when an active simulation exists' do
      let!(:simulation) do
        create(:simulation, state: 'queued', profile: profile)
      end

      it { expect(profile.scheduled?).to be_true }
    end

    context 'when no active simulation for the profile exists' do
      it { expect(profile.scheduled?).to be_false }
    end
  end

  describe '#profile_matches_simulator' do
    let!(:simulator) { create(:simulator) }
    let!(:simulator_instance) do
      create(:simulator_instance, simulator: simulator)
    end
    it 'passes only when all the strategies/roles are on the simulator' do
      simulator.add_strategy('All', 'A')
      profile = build(:profile, simulator_instance: simulator_instance,
                                assignment: 'All: 2 A')
      expect(profile.valid?).to be_true
    end

    it 'fails when the strategy is not present on the simulator' do
      profile = build(:profile, simulator_instance: simulator_instance,
                                assignment: 'All: 2 A')
      expect(profile.valid?).to be_false
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
      create(:simulation, profile: profile)
      expect(profile.reload.scheduled?).to be_true
    end

    it 'returns false is the profile does not have scheduled simulations' do
      expect(profile.scheduled?).to be_false
    end
  end
end
