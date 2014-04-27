require 'spec_helper'

# Always test with JRuby for things like this before committing
# No true threading in MRI
describe 'Concurrent data parsing does not lead to problems' do
  let!(:profile) do
    create(:profile,
           assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2')
  end
  let!(:simulation1) do
    create(:simulation, profile: profile, state: 'running')
  end
  let!(:simulation2) do
    create(:simulation, profile: profile, state: 'running')
  end
  let!(:simulation3) do
    create(:simulation, profile: profile, state: 'running')
  end

  it 'works the same way every time' do
    files = [3, 4, 5].map { |i| "#{Rails.root}/spec/support/data/#{i}" }
    threads = []
    parsers = [DataParser.new, DataParser.new, DataParser.new].zip(
      [simulation1.id, simulation2.id, simulation3.id], files)
    parsers.shuffle.each do |parser|
      threads.append(Thread.new { parser[0].perform(parser[1], parser[2]) })
    end
    threads.each do |t|
      t.join
    end
    expect(Player.count).to eq(32)
    Observation.all.each do |o|
      o.observation_aggs.each do |agg|
        query = Player.where(observation_id: agg.observation_id,
                             symmetry_group_id: agg.symmetry_group_id)
        mean = query.average(:payoff)
        expect(agg.payoff).to be_within(0.0001).of(mean)
        sum_sq = query.pluck(:payoff).map { |p| (p - mean)**2 }.reduce(:+)
        std_dev = Math.sqrt(sum_sq / (query.count - 1))
        unless sum_sq == 0
          expect(agg.payoff_sd).to be_within(0.0001).of(std_dev)
        end
      end
    end
    SymmetryGroup.all.each do |s|
      query = ObservationAgg.where(symmetry_group_id: s.id)
      mean = query.average(:payoff)
      expect(s.payoff).to be_within(0.0001).of(mean)
      sum_sq = query.pluck(:payoff).map { |p| (p - mean)**2 }.reduce(:+)
      std_dev = Math.sqrt(sum_sq / (query.count - 1))
      expect(s.sum_sq_diff).to be_within(0.0001).of(sum_sq)
      expect(s.payoff_sd).to be_within(0.0001).of(std_dev)
      adj_mean = query.average(:adjusted_payoff)
      expect(s.adjusted_payoff).to be_within(0.0001).of(adj_mean)
      adj_sum_sq = query.pluck(:adjusted_payoff).map { |p| (p - mean)**2 }
        .reduce(:+)
      adj_std_dev = Math.sqrt(adj_sum_sq / (query.count - 1))
      expect(s.payoff_sd).to be_within(0.0001).of(std_dev)
      expect(s.adj_sum_sq_diff).to be_within(0.0001).of(adj_sum_sq)
    end
  end
end
