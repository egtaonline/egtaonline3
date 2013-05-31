require 'spec_helper'

describe Game do
  describe '#profile_space' do
    let(:game){ FactoryGirl.create(:game, size: 2) }

    before do
      game.roles.create(name: 'All', count: 2, reduced_count: 2, strategies: ['A', 'B'])
    end

    it { game.profile_space.should == ['All: 2 A', 'All: 1 A, 1 B', 'All: 2 B'] }
  end
end
