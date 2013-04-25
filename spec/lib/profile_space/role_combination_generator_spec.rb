require 'profile_space/role_combination_generator'

describe RoleCombinationGenerator do
  describe 'combinations' do
    it 'returns strategy combinations with the role appended' do
      RoleCombinationGenerator.combinations('All', ['A', 'B'], 2).should ==[['All', 'A', 'A'],
                                                                             ['All', 'A', 'B'],
                                                                             ['All', 'B', 'B']]
    end
  end
end