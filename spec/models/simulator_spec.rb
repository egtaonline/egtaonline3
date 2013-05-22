require 'spec_helper'

describe Simulator do
  describe 'setup/validation:' do
    before :all do
      Simulator.set_callback(:validation, :before, :setup_simulator, if: :source_changed?)
    end

    after :all do
      Simulator.skip_callback(:validation, :before, :setup_simulator, if: :source_changed?)
    end
    context 'with valid simulator' do
      context 'new simulator' do
        it 'sets up the simulator, locally and on the backend' do
          Backend.should_receive(:prepare_simulator)
          simulator = Simulator.create!(name: 'fake_sim', version: '1.0', email: 'test@example.com',
                                        source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          simulator.configuration.should == { "parm-integer" => "60", "parm-float" => "0.0", "parm-string" => "CDA" }
        end
      end

      context 'existing simulator' do
        it 'replaces the existing simulator, locally and on the backend' do
          simulator = Simulator.create!(name: 'fake_sim', version: '1.0', email: 'test@example.com',
                                        source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          simulator.configuration["parm-integer"] = 61
          simulator.save!
          Backend.should_receive(:prepare_simulator).with(simulator)
          FileUtils.should_receive(:rm_rf).with(File.join(Rails.root, 'simulator_uploads', simulator.fullname))
          simulator.update_attributes(source: File.new("#{Rails.root}/spec/support/data/fake_sim.zip"))
          simulator.configuration.should == { "parm-integer" => "60", "parm-float" => "0.0", "parm-string" => "CDA" }
        end
      end
    end
  end

  let(:simulator){ FactoryGirl.create(:simulator) }

  describe '#add_role' do
    it "adds a new empty role" do
      simulator.add_role("All")
      simulator.reload.role_configuration.should == { "All" => [] }
    end
  end

  describe '#remove_role' do
    it "removes the role if present" do
      simulator.role_configuration = { "All" => ["A1"] }
      simulator.save!
      simulator.reload.remove_role("B")
      simulator.reload.role_configuration.should == { "All" => ["A1"] }
      simulator.remove_role("All")
      simulator.reload.role_configuration.should == { }
    end
  end

  describe '#add_strategy' do
    it 'adds the strategy to specified role' do
      simulator.add_strategy('All', 'A1')
      simulator.add_strategy('All', 'A2')
      simulator.reload.role_configuration.should == { "All" => ["A1", "A2"] }
    end
  end

  describe '#remove_strategy' do
    it 'removes the specified strategy from the specified role if possible' do
      simulator.role_configuration = { 'Role1' => ['A', 'B'], 'Role2' => ['A'] }
      simulator.remove_strategy('Role1', 'A')
      simulator.reload.role_configuration.should == { 'Role1' => ['B'], 'Role2' => ['A'] }
      simulator.remove_strategy('Role2', 'B')
      simulator.reload.role_configuration.should == { 'Role1' => ['B'], 'Role2' => ['A'] }
    end
  end
end
