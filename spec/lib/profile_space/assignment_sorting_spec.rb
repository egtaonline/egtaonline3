require 'profile_space/assignment_sorting'

describe 'String#assignment_sort' do
  let(:unsorted_string) { 'B: 1 D, 2 E; A: 3 G, 2 F' }
  it do
    expect(unsorted_string.assignment_sort).to eq('A: 2 F, 3 G; B: 1 D, 2 E')
  end
end
