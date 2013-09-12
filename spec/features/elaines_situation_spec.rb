require 'spec_helper'

describe 'waiting for the files to show up' do
  context 'error file is missing' do
    let!(:profile){ FactoryGirl.create(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let!(:simulation){ FactoryGirl.create(:simulation, state: 'queued', size: 2, profile: profile, id: 3) }
    let!(:scheduling_requirement){ FactoryGirl.create(:scheduling_requirement, profile: simulation.profile) }

    it 'does nothing' do
      s = SimulationStatusResolver.new("#{Rails.root}/spec/support/data/")
      s.act_on_status("C", simulation)
      Timecop.freeze(Time.now + 6.minutes) do
        Simulation.count.should == 1
        simulation.reload.state.should == 'running'
      end
    end
  end
end