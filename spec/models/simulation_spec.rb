require 'spec_helper'

describe Simulation do
  describe '.scheduled' do
    context 'when a mixture of simulation states exist' do
      before do
        ['pending', 'queued', 'running', 'failed', 'running', 'complete', 'processing'].each do |state|
          FactoryGirl.create(:simulation, state: state)
        end
      end
      
      it 'returns only simulations with state in [:pending, :queued, :running]' do
        Simulation.scheduled.pluck(:state).sort.should == ['pending', 'queued', 'running', 'running'].sort
      end
    end
  end
end
