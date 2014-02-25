require 'backend/flux/pbs_path_finder'

describe PbsPathFinder do
  let(:simulators_path){ 'path/to/simulators'}
  let(:data_path){ 'path/to/data'}
  let(:simulator){ double(fullname: 'sim-ver2', name: 'sim') }
  let(:simulation){ double(id: 1) }
  subject { PbsPathFinder.new(simulation, simulator, simulators_path, data_path) }

  its(:simulator_path){ should == File.join(simulators_path, simulator.fullname, simulator.name) }
  its(:simulation_path){ should == File.join(data_path, simulation.id.to_s) }
  its(:output_path){ should == File.join(data_path, simulation.id.to_s, 'out') }
  its(:error_path){ should == File.join(data_path, simulation.id.to_s, 'error') }
  its(:data_path){ should == data_path }
end