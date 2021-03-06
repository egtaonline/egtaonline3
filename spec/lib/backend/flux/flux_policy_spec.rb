require 'backend/flux/flux_policy'

describe FluxPolicy do
  # Test mock
  class FluxPolicy
    class Simulation
    end
  end

  let(:flux_policy) { FluxPolicy.new(100) }
  let(:simulation) { double('simulation') }

  # not testing all edge cases because it's a mathematical statement
  describe '#assign_queue' do
    context 'when there are no active simulations' do
      before do
        FluxPolicy::Simulation.should_receive(:active_on_flux).and_return([])
        FluxPolicy::Simulation.should_receive(:active_on_other).and_return([])
      end

      it 'updates qos of the simulation to flux and returns the simulation' do
        simulation.should_receive(:update_attributes).with(qos: 'flux')
        expect(flux_policy.assign_queue(simulation)).to eq(simulation)
      end
    end

    context 'when it should not be sent to flux' do
      before do
        criteria = double(count: 105)
        FluxPolicy::Simulation.should_receive(:active_on_flux)
          .and_return(criteria)
        FluxPolicy::Simulation.should_receive(:active_on_other).and_return([])
      end

      it 'updates the simulation for engin_flux and returns the simulation' do
        simulation.should_receive(:update_attributes).with(qos: 'engin_flux')
        expect(flux_policy.assign_queue(simulation)).to eq(simulation)
      end
    end
  end
end
