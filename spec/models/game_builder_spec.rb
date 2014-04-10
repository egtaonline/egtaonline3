require 'spec_helper'

describe GameBuilder do
  describe 'create' do
    let(:simulator) { create(:simulator, :with_strategies) }
    let(:configuration) do
      { 'fake' => 'variable', 'fake2' => 'other_variable' }
    end
    let(:params) { { 'name' => 'test', 'size' => 2 } }

    context 'when a matching SimulatorInstance exists' do
      before do
        @simulator_instance = SimulatorInstance.create(
          simulator_id: simulator.id, configuration: configuration)
        @game = GameBuilder.create(params, simulator.id, configuration)
      end

      it { expect(@game.name).to eq('test') }
      it { expect(@game.simulator_instance_id).to eq(@simulator_instance.id) }
    end

    context 'when a matching SimulatorInstance does not exist' do
      before do
        @game = GameBuilder.create(params, simulator.id, configuration)
        @simulator_instance = SimulatorInstance.last
      end

      it { expect(@game.name).to eq('test') }
      it { expect(@game.simulator_instance_id).to eq(@simulator_instance.id) }
      it { expect(@simulator_instance.simulator_id).to eq(simulator.id) }
      it { expect(@simulator_instance.configuration).to eq(configuration) }
    end
  end

  describe 'create_game_to_match' do
    SCHEDULER_CLASSES.each do |scheduler_klass|
      context "when using a #{scheduler_klass}" do
        before do
          @scheduler = create(scheduler_klass, :with_profiles)
          @game = GameBuilder.create_game_to_match(@scheduler)
        end

        [:name, :size, :simulator_instance_id].each do |field|
          it { expect(@game.send(field)).to eq(@scheduler.send(field)) }
        end

        it do
          expect(@game.roles.map do |role|
            { name: role.name, count: role.count, strategies: role.strategies }
          end).to eq(@scheduler.roles.map do |role|
            { name: role.name, count: role.count,
              strategies: role.strategies + role.deviating_strategies }
          end)
        end
      end
    end
  end
end
