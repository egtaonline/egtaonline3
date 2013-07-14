require 'spec_helper'

describe GamePresenter do
  let(:game){ FactoryGirl.create(:game, :with_strategies) }
  let!(:profile){ FactoryGirl.create(:profile, :with_observations, simulator_instance_id: game.simulator_instance_id, assignment: 'Role1: 2 A, 1 B; Role2: 2 C') }
  let!(:profile2){ FactoryGirl.create(:profile, :with_observations, simulator_instance_id: game.simulator_instance_id, assignment: 'Role1: 3 B; Role2: 2 C') }
  subject{ GamePresenter.new(game) }

  describe '#to_json' do
    context 'when granularity is specified as summary' do
      let(:response) do
<<HEREDOC
{"id":#{game.id},"name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.collect{|k,v| [k,v.to_s]}.to_json},"roles":[{"name":"Role1","strategies":["A","B"],"count":3},{"name":"Role2","strategies":["C","D"],"count":2}],"profiles":[{"id":#{profile.id},"observations_count":#{profile.observations_count},"symmetry_groups":[{"id":#{profile.symmetry_groups[0].id},"role":"Role1","strategy":"A","count":2,"payoff":100,"payoff_sd":0},{"id":#{profile.symmetry_groups[1].id},"role":"Role1","strategy":"B","count":1,"payoff":100,"payoff_sd":null},{"id":#{profile.symmetry_groups[2].id},"role":"Role2","strategy":"C","count":2,"payoff":100,"payoff_sd":0}]},{"id":#{profile2.id},"observations_count":#{profile.observations_count},"symmetry_groups":[{"id":#{profile2.symmetry_groups[0].id},"role":"Role1","strategy":"B","count":3,"payoff":100,"payoff_sd":0},{"id":#{profile2.symmetry_groups[1].id},"role":"Role2","strategy":"C","count":2,"payoff":100,"payoff_sd":0}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'summary').should eql(response.chomp) }
    end

    context 'when granularity is specified as observations' do
      let(:response) do
<<HEREDOC
{"id":#{game.id},"name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.collect{|k,v| [k,v.to_s]}.to_json},"roles":[{"name":"Role1","strategies":["A","B"],"count":3},{"name":"Role2","strategies":["C","D"],"count":2}],"profiles":[{"id":#{profile.id},"symmetry_groups":[{"id":#{profile.symmetry_groups[0].id},"role":"Role1","strategy":"A","count":2},{"id":#{profile.symmetry_groups[1].id},"role":"Role1","strategy":"B","count":1},{"id":#{profile.symmetry_groups[2].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"symmetry_groups":[{"id":#{profile.symmetry_groups[0].id},"payoff":100,"payoff_sd":0},{"id":#{profile.symmetry_groups[1].id},"payoff":100,"payoff_sd":null},{"id":#{profile.symmetry_groups[2].id},"payoff":100,"payoff_sd":0}]}]},{"id":#{profile2.id},"symmetry_groups":[{"id":#{profile2.symmetry_groups[0].id},"role":"Role1","strategy":"B","count":3},{"id":#{profile2.symmetry_groups[1].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"symmetry_groups":[{"id":#{profile2.symmetry_groups[0].id},"payoff":100,"payoff_sd":0},{"id":#{profile2.symmetry_groups[1].id},"payoff":100,"payoff_sd":0}]}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'observations').should eql(response.chomp) }
    end

    context 'when granularity is specified as full granularity' do
      let(:response) do
<<HEREDOC
{"id":#{game.id},"name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.collect{|k,v| [k,v.to_s]}.to_json},"roles":[{"name":"Role1","strategies":["A","B"],"count":3},{"name":"Role2","strategies":["C","D"],"count":2}],"profiles":[{"id":#{profile.id},"symmetry_groups":[{"id":#{profile.symmetry_groups[0].id},"role":"Role1","strategy":"A","count":2},{"id":#{profile.symmetry_groups[1].id},"role":"Role1","strategy":"B","count":1},{"id":#{profile.symmetry_groups[2].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"players":[{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[1].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[2].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[2].id}}]}]},{"id":#{profile2.id},"symmetry_groups":[{"id":#{profile2.symmetry_groups[0].id},"role":"Role1","strategy":"B","count":3},{"id":#{profile2.symmetry_groups[1].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"players":[{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[1].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[1].id}}]}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'full').should eql(response.chomp) }
    end
  end
end