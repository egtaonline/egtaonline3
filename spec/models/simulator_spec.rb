require 'spec_helper'

describe Simulator do
  describe 'setup/validation:' do
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
end
