require 'spec_helper'

describe SymmetryGroup do
  let!(:profile){ FactoryGirl.create(:profile, :with_observations,
    assignment: 'All: 2 A') }
  let(:symmetry_group){ profile.symmetry_groups.first }

  before do
    players = symmetry_group.players
    players.first.update_attributes(payoff: 200)
    players.last.update_attributes(payoff: 400)
  end
  describe '#payoff' do
    it 'averages the player payoffs' do
      symmetry_group.payoff.should == 300.0
    end
  end

  describe '#payoff_sd' do
    it 'returns an estimate of the sd for payoffs' do
      symmetry_group.payoff_sd.round(5).should ==
        Math.sqrt(((400-300)**2+(200-300)**2)).round(5)
    end
  end
end
