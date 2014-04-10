require 'profile_space/subgame_creator'

describe SubgameCreator do
  describe 'subgame_assignments' do
    it 'returns array of profile assignments consistent with a single role' do
      roles = [stub(name: 'All', strategies: %w(A B), reduced_count: 2)]
      expect(SubgameCreator.subgame_assignments(roles))
        .to eq([[%w(All A A)], [%w(All A B)], [%w(All B B)]])
    end

    it 'returns array of profile assignments consistent with multiple roles' do
      roles = [stub(name: 'First', strategies: %w(A B), reduced_count: 1),
               stub(name: 'Second', strategies: %w(D), reduced_count: 2)]
      expect(SubgameCreator.subgame_assignments(roles))
        .to eq([[%w(First A), %w(Second D D)], [%w(First B), %w(Second D D)]])

    end
  end
end
