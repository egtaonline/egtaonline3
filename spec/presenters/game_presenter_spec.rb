require 'spec_helper'

describe GamePresenter do
  let(:game){ FactoryGirl.create(:game, :with_strategies) }
  let!(:profile){ FactoryGirl.create(:profile, :with_observations, simulator_instance_id: game.simulator_instance_id, assignment: 'Role1: 2 A, 1 B; Role2: 2 C') }
  let!(:profile2){ FactoryGirl.create(:profile, :with_observations, simulator_instance_id: game.simulator_instance_id, assignment: 'Role1: 3 B; Role2: 2 C') }
  subject{ GamePresenter.new(game) }

  describe '#to_json' do
    context 'when granularity is specified as summary' do
      it "makes the correct json" do
        location = subject.to_json(granularity: 'summary')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile_summary(json, profile)
        validate_profile_summary(json, profile2)
      end
    end

    context 'when granularity is specified as observations' do
      it "makes the correct json" do
        location = subject.to_json(granularity: 'observations')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile_observations(json, profile)
        validate_profile_observations(json, profile2)
      end
    end

    context 'when granularity is specified as full granularity' do
      let(:response) do
<<HEREDOC
{"id":#{game.id},"name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.collect{|k,v| [k,v.to_s]}.to_json},"roles":[{"name":"Role1","strategies":["A","B"],"count":3},{"name":"Role2","strategies":["C","D"],"count":2}],"profiles":[{"id":#{profile.id},"symmetry_groups":[{"id":#{profile.symmetry_groups[0].id},"role":"Role1","strategy":"A","count":2},{"id":#{profile.symmetry_groups[1].id},"role":"Role1","strategy":"B","count":1},{"id":#{profile.symmetry_groups[2].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"players":[{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[1].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[2].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile.symmetry_groups[2].id}}]}]},{"id":#{profile2.id},"symmetry_groups":[{"id":#{profile2.symmetry_groups[0].id},"role":"Role1","strategy":"B","count":3},{"id":#{profile2.symmetry_groups[1].id},"role":"Role2","strategy":"C","count":2}],"observations":[{"features":{},"players":[{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[0].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[1].id}},{"payoff":100,"features":{},"symmetry_group_id":#{profile2.symmetry_groups[1].id}}]}]}]}
HEREDOC
      end
      it "makes the correct json" do
        location = subject.to_json(granularity: 'full')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile_full(json, profile)
        validate_profile_full(json, profile2)
      end
    end
  end

  private

  def validate_basics(json, game)
    json["id"].should == game.id
    json["name"].should == game.name
    json["simulator_fullname"].should == game.simulator_fullname
    json["configuration"].should == game.configuration.to_a.collect{ |e| [e[0], e[1].to_s] }
    json["roles"].should include({ "name" => "Role1", "strategies" => ["A","B"], "count" => 3 })
    json["roles"].should include({ "name" => "Role2", "strategies" => ["C","D"], "count" => 2 })
  end

  def validate_profile_observations(json, profile)
    profile_json = json["profiles"].detect{ |p| p["id"] == profile.id }
    profile.symmetry_groups.each do |symmetry_group|
      profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy, "count" => symmetry_group.count })
    end
    profile_json["observations"].size.should == profile.observations_count
    profile.observations.each do |observation|
      obs = profile_json["observations"].detect do |o|
        flag = true
        observation.observation_aggs.each do |agg|
          flag = flag && o["symmetry_groups"].include?({ "id" => agg.symmetry_group_id, "payoff" => agg.payoff, "payoff_sd" => agg.payoff_sd })
        end
        flag && o["features"] == observation.features
      end
      obs.should_not == nil
    end
  end

  def validate_profile_summary(json, profile)
    profile_json = json["profiles"].detect{ |p| p["id"] == profile.id }
    profile_json["observations_count"].should == profile.observations_count
    profile.symmetry_groups.each do |symmetry_group|
      profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy,
        "count" => symmetry_group.count, "payoff" => symmetry_group.payoff, "payoff_sd" => symmetry_group.payoff_sd })
    end
  end

  def validate_profile_full(json, profile)
    profile_json = json["profiles"].detect{ |p| p["id"] == profile.id }
    profile.symmetry_groups.each do |symmetry_group|
      profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy, "count" => symmetry_group.count })
    end
    profile_json["observations"].size.should == profile.observations_count
    profile.observations.each do |observation|
      obs = profile_json["observations"].detect do |o|
        flag = true
        observation.players.each do |player|
          flag = flag && o["players"].include?({ "sid" => player.symmetry_group_id, "p" => player.payoff, "f" => player.features, "e" => player.extended_features })
        end
        flag && o["features"] == observation.features
      end
      obs.should_not == nil
    end
  end
end