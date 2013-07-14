require 'spec_helper'

describe ProfilePresenter do
  describe '#to_json' do
    let!(:profile){ FactoryGirl.create(:profile, :with_observations,
      assignment: 'Role1: 2 A, 1 B; Role2: 2 C') }
    let(:presenter){ ProfilePresenter.new(profile) }
    context 'when the granularity is summary' do
      let(:response) do
        "{\"id\":#{profile.id},\"observations_count\":" +
        "#{profile.observations_count},\"simulator_instance_id\":" +
        "#{profile.simulator_instance_id},\"symmetry_groups\":" +
        profile.symmetry_groups.collect do |symmetry_group|
          { id: symmetry_group.id, role: symmetry_group.role,
            strategy: symmetry_group.strategy, count: symmetry_group.count,
            payoff: 100, payoff_sd: (symmetry_group.count > 1 ? 0 : nil) }
        end.to_json + "}"
      end

      it "returns the expected json" do
        presenter.to_json(granularity: "summary").should == response
      end
    end

    context 'when the granularity is observations' do
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
            symmetry_groups: profile.symmetry_groups.collect do |symmetry_group|
              { id: symmetry_group.id, payoff: 100,
                payoff_sd:(symmetry_group.count > 1 ? 0 : nil) }
            end }
        end.to_json + "}"
      end

      it "returns the expected json" do
        presenter.to_json(granularity: "observations").should == response
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
        presenter.to_json(granularity: "full").should == response
      end
    end
  end
end