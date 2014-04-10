require 'backend/flux/pbs_path_finder'

describe PbsPathFinder do
  let(:simulators_path) { 'path/to/simulators' }
  let(:data_path) { 'path/to/data' }
  let(:simulator) { double(fullname: 'sim-ver2', name: 'sim') }
  let(:simulation) { double(id: 1) }
  subject do
    PbsPathFinder.new(simulation, simulator, simulators_path, data_path)
  end

  its(:simulator_path) do
    should eq(File.join(simulators_path, simulator.fullname, simulator.name))
  end
  its(:simulation_path) { should eq(File.join(data_path, simulation.id.to_s)) }
  its(:output_path) do
    should eq(File.join(data_path, simulation.id.to_s, 'out'))
  end
  its(:error_path) do
    should eq(File.join(data_path, simulation.id.to_s, 'error'))
  end
  its(:data_path) { should eq(data_path) }
end
