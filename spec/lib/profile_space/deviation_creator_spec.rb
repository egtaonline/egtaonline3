require 'profile_space/deviation_creator'

describe DeviationCreator do
  describe 'deviation_assignments' do
    it 'returns assignments for single player deviations' do
      roles = [stub(name: 'All', strategies: %w(A B),
                    deviating_strategies: %w(C D), reduced_count: 2)]
      deviation_assignments = DeviationCreator.deviation_assignments(roles)
      expect(deviation_assignments).to eq([[%w(All A C)],
                                           [%w(All A D)],
                                           [%w(All B C)],
                                           [%w(All B D)]])
    end

    it 'returns assignments that deviate from target set for multiple roles' do
      roles = [stub(name: 'First', strategies: %w(A),
                    deviating_strategies: %w(E), reduced_count: 1),
               stub(name: 'Second', strategies: %w(D),
                    deviating_strategies: %w(F G), reduced_count: 2)]
      deviation_assignments = DeviationCreator.deviation_assignments(roles)
      expect(deviation_assignments).to eq([[%w(First E), %w(Second D D)],
                                           [%w(First A), %w(Second D F)],
                                           [%w(First A), %w(Second D G)]])
    end
  end
end
