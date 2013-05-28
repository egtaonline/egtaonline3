require 'spec_helper'

describe GamePresenter do
  let(:game){ FactoryGirl.create(:game, :with_strategies) }
  let(:profile){ FactoryGirl.create(:profile, :with_observations, simulator_instance_id: game.simulator_instance_id, assignment: 'All: 2 A') }
  let(:symmetry_group){ profile.symmetry_groups.first }

  subject{ GamePresenter.new(game) }

  describe '#to_json' do
    context 'full granularity' do
      let(:response) do
<<HEREDOC
{"id":#{game.id},"name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.to_json},"roles":[{"name":"All","strategies":["A","B"],"count":2}],"profiles":[{"id":"#{profile.id}","symmetry_groups":[{"id":#{symmetry_group.id},"role":"#{symmetry_group.role}","strategy":"#{symmetry_group.strategy}","count":#{symmetry_group.count}}],"observations":[{"features":{},"players":[{"features":{},"payoff":100,"symmetry_group_id":#{symmetry_group.id}},{"features":{},"payoff":100,"symmetry_group_id":#{symmetry_group.id}}]}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'full').should eql(response) }
    end
  end
end