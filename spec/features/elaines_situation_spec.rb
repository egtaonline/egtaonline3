require 'spec_helper'

describe 'rescheduling simulations on failure' do
  context 'single invalid observation' do
    let!(:profile){ FactoryGirl.create(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let!(:simulation){ FactoryGirl.create(:simulation, state: 'queued', size: 2, profile: profile) }
    let!(:scheduling_requirement){ FactoryGirl.create(:scheduling_requirement, profile: simulation.profile) }

    it 'requests requeuing' do
      simulation.process("#{Rails.root}/spec/support/data/3")
      Timecop.freeze(Time.now + 6.minutes) do
        Simulation.count.should == 2
        Simulation.first.state.should == 'complete'
      end
    end
  end
end