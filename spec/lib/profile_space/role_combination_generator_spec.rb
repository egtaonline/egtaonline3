require 'profile_space/role_combination_generator'

describe RoleCombinationGenerator do
  describe 'combinations' do
    it 'returns strategy combinations with the role appended' do
      expect(RoleCombinationGenerator.combinations('All', %w(A B), 2))
        .to eq([%w(All A A), %w(All A B), %w(All B B)])
    end
  end
end
