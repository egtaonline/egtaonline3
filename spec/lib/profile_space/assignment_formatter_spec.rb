require 'profile_space/assignment_formatter'

describe AssignmentFormatter do
  describe 'format_assignment' do
    let(:input) { [%w(Second D D), %w(First B A)] }

    it 'converts an array-representation of the assignment to a string' do
      expect(AssignmentFormatter.format_assignment(input))
        .to eq('First: 1 A, 1 B; Second: 2 D')
    end
  end
end
