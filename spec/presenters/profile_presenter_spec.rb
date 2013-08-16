require 'spec_helper'

describe ProfilePresenter do
  describe '#to_json' do
    let!(:profile){ FactoryGirl.create(:profile, :with_observations,
      assignment: 'Role1: 2 A, 1 B; Role2: 2 C') }
    let(:presenter){ ProfilePresenter.new(profile) }
    context 'when the granularity is summary' do
      it "returns the expected json" do
        profile_json = MultiJson.load(presenter.to_json(granularity: "summary"))
        profile_json["id"].should == profile.id
        profile_json["observations_count"].should == profile.observations_count
        profile_json["simulator_instance_id"].should == profile.simulator_instance_id
        profile.symmetry_groups.each do |symmetry_group|
          profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy,
            "count" => symmetry_group.count, "payoff" => symmetry_group.payoff, "payoff_sd" => symmetry_group.payoff_sd })
        end
      end
    end

    context 'when the granularity is observations' do
      it "returns the expected json" do
        profile_json = MultiJson.load(presenter.to_json(granularity: "observations"))
        profile_json["id"].should == profile.id
        profile_json["simulator_instance_id"].should == profile.simulator_instance_id
        profile.symmetry_groups.each do |symmetry_group|
          profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy, "count" => symmetry_group.count })
        end
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
    end

    context 'when the granularity is full' do
      let(:response) do
        "{\"id\":#{profile.id},\"simulator_instance_id\":" +
        "#{profile.simulator_instance_id},\"symmetry_groups\":" +
        profile.symmetry_groups.collect do |symmetry_group|
          { id: symmetry_group.id, role: symmetry_group.role,
            strategy: symmetry_group.strategy, count: symmetry_group.count,
          }
        end.to_json + ",\"observations\":" +
        profile.observations.collect do |observation|
          { features: observation.features,
            players: observation.players.collect do |player|
              { symmetry_group_id: player.symmetry_group_id,
                payoff: 100, features: player.features }
            end }
        end.to_json + "}"
      end

      it "returns the expected json" do
        profile_json = MultiJson.load(presenter.to_json(granularity: "full"))
        profile_json["id"].should == profile.id
        profile_json["simulator_instance_id"].should == profile.simulator_instance_id
        profile.symmetry_groups.each do |symmetry_group|
          profile_json["symmetry_groups"].should include({ "id" => symmetry_group.id, "role" => symmetry_group.role, "strategy" => symmetry_group.strategy, "count" => symmetry_group.count })
        end
        profile.observations.each do |observation|
          obs = profile_json["observations"].detect do |o|
            flag = true
            observation.players.each do |player|
              flag = flag && o["players"].include?({ "sid" => player.symmetry_group_id, "p" => player.payoff, "f" => player.features })
            end
            flag && o["features"] == observation.features
          end
          obs.should_not == nil
        end
      end
    end
  end
end