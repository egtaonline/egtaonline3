require 'spec_helper'

describe 'waiting for the files to show up' do
  context 'error file is missing' do
    let!(:profile) do
      create(:profile,
             assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2')
    end
    let!(:simulation) do
      create(:simulation, state: 'queued', size: 2, profile: profile, id: 3)
    end
    let!(:scheduling_requirement) do
      create(:scheduling_requirement, profile: simulation.profile)
    end

    it 'does nothing' do
      s = SimulationStatusResolver.new("#{Rails.root}/spec/support/data/")
      s.act_on_status('C', simulation)
      Timecop.freeze(Time.now + 6.minutes) do
        expect(Simulation.count).to eq(1)
        expect(simulation.reload.state).to eq('running')
      end
    end
  end
end
