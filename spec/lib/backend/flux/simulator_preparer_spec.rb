# require 'backend/flux/simulator_preparer'
#
# describe SimulatorPreparer do
#   subject{ S}
#
#   describe '#prepare' do
#     let(:simulator){ double(name: 'sim', simulator_source: double(path: 'path/to/simulator')) }
#
#     it 'removes the old copy of the simulator' do
#       FileUtils.should_receive(:rm_rf).with('path)
#     end
#       before 'cleans up the space and uploads the simulator' do
#         simulator_prep_service.should_receive(:cleanup_simulator).with(simulator)
#         flux_proxy.should_receive(:upload!).with('path/to/simulator', "fake/simulators/path/sim.zip", recursive: true).and_return("")
#         flux_proxy.should_receive(:exec!).with("[ -f \"fake/simulators/path/sim.zip\" ] && echo \"exists\" || echo \"not exists\"")
#         simulator_prep_service.should_receive(:prepare_simulator).with(simulator)
#       end
#
#       it { subject.prepare_simulator(simulator) }
#     end
#   end
# end