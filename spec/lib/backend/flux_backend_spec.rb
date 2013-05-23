require 'spec_helper'

describe FluxBackend do
  describe 'authenticate' do
    let(:flux_proxy){ double('submit_connection') }
    let(:uniqname){ 'Fake' }
    let(:password){ 'More fake' }
    let(:verification_number){ 'Also fake' }
    let(:flux_backend){ FluxBackend.new }

    before do
      DRbObject.stub(:new_with_uri).with('druby://localhost:30000').and_return(flux_proxy)
    end

    [true, false].each do |truth|
      context "when flux proxy returns #{truth}" do
        before do
          flux_proxy.should_receive(:authenticate).with(uniqname, verification_number, password).and_return(truth)
          flux_backend.setup_connections
        end

        it { flux_backend.authenticate(uniqname: uniqname, verification_number: verification_number, password: password).should == truth }
      end
    end

    context 'when it raise an error' do
      before do
        flux_proxy.should_receive(:authenticate).with(uniqname, verification_number, password).and_raise(Exception)
        flux_backend.setup_connections
      end

      it { flux_backend.authenticate(uniqname: uniqname, verification_number: verification_number, password: password).should == false }
    end
  end
end