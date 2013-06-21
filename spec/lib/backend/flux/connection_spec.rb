# require 'backend/flux/connection'
#
# describe Connection do
#   describe '#authenticate' do
#     let(:uniqname){ 'Fake' }
#     let(:password){ 'More fake' }
#     let(:verification_number){ 'Also fake' }
#
#     [true, false].each do |truth|
#       context "when flux proxy returns #{truth}" do
#         before do
#           flux_proxy.should_receive(:authenticate).with(uniqname, verification_number, password).and_return(truth)
#         end
#
#         it { flux_backend.authenticate(uniqname: uniqname, verification_number: verification_number, password: password).should == truth }
#       end
#     end
#
#     context 'when it raise an error' do
#       before do
#         flux_proxy.should_receive(:authenticate).with(uniqname, verification_number, password).and_raise(Exception)
#       end
#
#       it { flux_backend.authenticate(uniqname: uniqname, verification_number: verification_number, password: password).should == false }
#     end
#   end
#
#   describe '#acquire' do
#     context 'when the connection is closed' do
#       it 'informs Backend that it is not connected'
#       it 'informs the caller that the connection is closed'
#     end
#
#     context 'when the connection is open' do
#       it 'returns the connection'
#       it 'synchronizes access to the connection'
#     end
#   end
# end