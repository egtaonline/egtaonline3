require 'spec_helper'

describe GameFactory do
  describe 'create_game_to_match' do
    SCHEDULER_CLASSES.each do |scheduler_klass|
      context "when using a #{scheduler_klass}" do
        before :all do
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