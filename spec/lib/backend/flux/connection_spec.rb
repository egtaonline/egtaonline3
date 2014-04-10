require 'backend/flux/connection'

describe Connection do
  let(:flux_proxy) { double('flux proxy') }
  let(:connection) { Connection.new(proxy: flux_proxy) }

  describe '#authenticate' do
    let(:uniqname) { 'Fake' }
    let(:password) { 'More fake' }
    let(:verification_number) { 'Also fake' }

    [true, false].each do |truth|
      context "when flux proxy returns #{truth}" do
        before do
          flux_proxy.should_receive(:authenticate).with(
            uniqname, verification_number, password).and_return(truth)
        end

        it do
          expect(connection.authenticate(
            uniqname: uniqname, verification_number: verification_number,
            password: password)).to eq(truth)
        end
      end
    end

    context 'when it raise an error' do
      before do
        flux_proxy.should_receive(:authenticate).with(
          uniqname, verification_number, password).and_raise(Exception)
      end

      it do
        expect(connection.authenticate(
          uniqname: uniqname, verification_number: verification_number,
          password: password)).to be false
      end
    end
  end

  describe '#acquire_connection_for' do
    context 'when the connection is closed' do
      # stubbing out Backend
      module Backend
      end

      before do
        flux_proxy.should_receive(:authenticated?).and_return(false)
      end

      it { expect(connection.acquire.nil?).to be true }
    end

    context 'when the connection is open' do
      before do
        flux_proxy.should_receive(:authenticated?).and_return(true)
      end

      it 'returns the connection' do
        expect(connection.acquire).to eq(flux_proxy)
      end
    end
  end
end
