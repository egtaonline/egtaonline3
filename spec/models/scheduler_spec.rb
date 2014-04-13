require 'spec_helper'

shared_examples 'a pattern-based scheduler class' do
  let(:scheduler) { create(described_class.to_s.underscore.to_sym) }

  it_behaves_like 'a scheduler class'

  before do
    scheduler.simulator.update_attributes(
      role_configuration: { 'A' => %w(A1 A2), 'B' => %w(B2) })
  end

  context 'stubbed out' do
    before do
      scheduler.stub(:update_requirements)
    end

    describe '#add_strategy' do
      it 'adds the strategy to specified role' do
        scheduler.add_role('A', 1)
        scheduler.add_role('B', 1)
        scheduler.add_strategy('A', 'A1')
        scheduler.add_strategy('A', 'A2')
        expect(scheduler.roles.where(name: 'A').first.strategies)
          .to eq(%w(A1 A2))
        expect(scheduler.roles.where(name: 'B').first.strategies)
          .to eq([])
      end
    end

    describe '#remove_strategy' do
      it 'removes the strategy from the role if possible' do
        scheduler.roles.create!(name: 'A', count: 1, reduced_count: 1,
                                strategies: %w(A1 A2))
        scheduler.roles.create!(name: 'B', count: 1, reduced_count: 1,
                                strategies: %w(B2))
        scheduler.remove_strategy('A', 'A1')
        scheduler.remove_strategy('B', 'B1')
        expect(scheduler.roles.where(name: 'A').first.strategies)
          .to eq(%w(A2))
        expect(scheduler.roles.where(name: 'B').first.strategies)
          .to eq(%w(B2))
      end
    end

    describe '#invalid_role_partition?' do
      it 'returns true if there are no strategies on one of the roles' do
        scheduler.add_role('A', 1)
        scheduler.add_role('B', 1)
        scheduler.add_strategy('A', 'A1')
        expect(scheduler.invalid_role_partition?).to be_true
      end

      it 'returns false when all players assigned & each role has strategy' do
        scheduler.add_role('A', 1)
        scheduler.add_role('B', 1)
        scheduler.add_strategy('A', 'A1')
        scheduler.add_strategy('B', 'B2')
        scheduler.reload
        expect(scheduler.invalid_role_partition?).to be_false
      end
    end
  end

  context 'when modifying role configuration with' do
    before do
      scheduler.should_receive(:update_requirements)
    end

    describe 'changing the size' do
      it 'triggers profile association' do
        scheduler.size = 8
        scheduler.save!
      end

      it 'destroys roles' do
        scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2)
        scheduler.size = 8
        scheduler.save!
        expect(scheduler.reload.roles.count).to eq(0)
        expect(Role.count).to eq(0)
      end
    end

    describe '#remove_role' do
      it 'triggers profile association' do
        scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2)
        scheduler.remove_role('A')
      end
    end

    describe '#add_strategy' do
      it 'triggers profile association' do
        scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2)
        scheduler.add_strategy('A', 'A1')
      end
    end

    describe '#remove_strategy' do
      it 'triggers profile association' do
        scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2,
                                strategies: %w(A1))
        scheduler.remove_strategy('A', 'A1')
      end
    end
  end
end

shared_examples 'a scheduler class' do
  let(:scheduler) { create(described_class.to_s.underscore.to_sym) }

  before do
    scheduler.simulator.update_attributes(
      role_configuration: { 'A' => %w(A1 A2), 'B' => %w(B2) })
  end

  describe '#add_role' do
    it 'adds the role to role_configuration' do
      scheduler.add_role('A', 2)
      expect(scheduler.roles.first.name).to eq('A')
      expect(scheduler.roles.first.count).to eq(2)
      expect(scheduler.roles.first.reduced_count).to eq(2)
      expect(scheduler.roles.first.strategies).to eq([])
    end
  end

  context 'stubbed out' do
    before do
      scheduler.stub(:update_requirements)
    end

    describe '#remove_role' do
      it 'removes the role if present' do
        scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2)
        scheduler.remove_role('B')
        expect(scheduler.roles.count).to eq(1)
        scheduler.remove_role('A')
        expect(scheduler.roles.count).to eq(0)
      end
    end

    describe '#invalid_role_partition?' do
      it 'returns true if the insufficient players have been assigned' do
        scheduler.add_role('A', 1)
        expect(scheduler.invalid_role_partition?).to be_true
      end
    end
  end

  describe '#unassigned_player_count' do
    it 'returns difference between scheduler size and sum of role counts' do
      scheduler.size = 4
      expect(scheduler.unassigned_player_count).to eq(4)
      scheduler.add_role('A', 2)
      scheduler.add_role('B', 1)
      expect(scheduler.unassigned_player_count).to eq(1)
    end
  end

  describe '#available_roles' do
    it 'shows the roles defined on simulator that are not on the scheduler' do
      simulator = scheduler.simulator_instance.simulator
      simulator.role_configuration = { 'A' => [], 'B' => [] }
      simulator.save!
      scheduler.add_role('A', 2)
      expect(scheduler.available_roles).to eq(['B'])
    end
  end

  describe '#available_strategies' do
    it 'shows the strategies for the role that are not on the scheduler' do
      scheduler.roles.create!(name: 'A', count: 2, reduced_count: 2,
                              strategies: %w(A2))
      expect(scheduler.available_strategies('A')).to eq(%w(A1))
    end
  end

  describe '#schedule_profile' do
    let(:profile) do
      create(:profile, simulator_instance: scheduler.simulator_instance,
                       observations_count: 3)
    end

    context 'when more observations are required' do
      context 'and the requirement is > the observation_per_simulation' do
        it 'creates a simulation with size of observation_per_simulation' do
          scheduler.schedule_profile(profile, 10)
          expect(Simulation.last.profile).to eq(profile)
          expect(Simulation.last.size)
            .to eq(scheduler.observations_per_simulation)
        end
      end

      context 'and the requirement is < the observation_per_simulation' do
        it 'creates simulation with size = requirement - observation count' do
          scheduler.schedule_profile(profile, 5)
          expect(Simulation.last.profile).to eq(profile)
          expect(Simulation.last.size).to eq(5 - profile.observations_count)
        end
      end
    end

    context 'when no observations are required' do
      it 'does not create a simulation' do
        scheduler.schedule_profile(profile, 2)
        expect(Simulation.count).to eq(0)
      end
    end
  end
end

describe GameScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end

describe DeviationScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end

describe DprDeviationScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end

describe DprScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end

describe GenericScheduler do
  it_behaves_like 'a scheduler class'

  describe '#invalid_role_partition?' do
    let(:scheduler) { create(:generic_scheduler) }

    it 'returns false when all the players are assigned' do
      scheduler.add_role('A', 1)
      scheduler.add_role('B', 1)
      expect(scheduler.invalid_role_partition?).to be_false
    end
  end
end

describe HierarchicalScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end

describe HierarchicalDeviationScheduler do
  it_behaves_like 'a pattern-based scheduler class'
end
