require 'spec_helper'

describe GameFactory do
  describe 'create' do
    let(:simulator){ FactoryGirl.create(:simulator, :with_strategies) }
    let(:configuration){ { 'fake' => 'variable', 'fake2' => 'other_variable' } }
    let(:params){ { 'name' => 'test' } }

    context "when a matching SimulatorInstance exists" do
      before do
        @simulator_instance = SimulatorInstance.create(simulator_id: simulator.id, configuration: configuration)
        @game = GameFactory.create(params, simulator.id, configuration)
      end

      it{ @game.name.should == 'test' }
      it{ @game.simulator_instance_id.should == @simulator_instance.id }
    end

    context "when a matching SimulatorInstance does not exist" do
      before do
        @game = GameFactory.create(params, simulator.id, configuration)
        @simulator_instance = SimulatorInstance.last
      end

      it{ @game.name.should == 'test' }
      it{ @game.simulator_instance_id.should == @simulator_instance.id }
      it{ @simulator_instance.simulator_id.should == simulator.id }
      it{ @simulator_instance.configuration.should == configuration }
    end
  end

  describe 'create_game_to_match' do
    SCHEDULER_CLASSES.each do |scheduler_klass|
      context "when using a #{scheduler_klass}" do
        before do
          @scheduler = FactoryGirl.create(scheduler_klass, :with_profiles)
          @game = GameFactory.create_game_to_match(@scheduler)
        end

        [:name, :size, :simulator_instance_id].each do |field|
          it { @game.send(field).should == @scheduler.send(field) }
        end

        it{ @game.roles.collect{|role| { name: role.name, count: role.count, strategies: role.strategies} }.should ==
            @scheduler.roles.collect{|role| { name: role.name, count: role.count, strategies: role.strategies+role.deviating_strategies } } }
      end
    end
  end
end