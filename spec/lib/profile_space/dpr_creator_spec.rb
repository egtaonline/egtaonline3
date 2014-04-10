require 'profile_space/dpr_creator'

describe DprCreator do
  describe 'expand_assignments' do
    it 'expands assignments consistent with role counts' do
      roles = [stub(name: 'EvenReduction', reduced_count: 1, count: 2),
               stub(name: 'UnevenReduction', reduced_count: 2, count: 5)]
      assignments = [[%w(EvenReduction A), %w(UnevenReduction B C)]]
      expect(DprCreator.expand_assignments(assignments, roles))
        .to eq([[%w(EvenReduction A A), %w(UnevenReduction B B B C C)],
                [%w(EvenReduction A A), %w(UnevenReduction B C C C C)],
                [%w(EvenReduction A A), %w(UnevenReduction B B B B C)]])
    end
  end
end
