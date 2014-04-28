require 'spec_helper'

describe ProfilePresenter do
  describe '#to_json' do
    let!(:profile) do
      create(:profile, :with_observations,
             assignment: 'Role1: 2 A, 1 B; Role2: 2 C')
    end
    let(:presenter) { ProfilePresenter.new(profile) }
    context 'when the granularity is summary' do
      it 'returns the expected json' do
        profile_json = MultiJson.load(
          presenter.to_json(granularity: 'summary'))
        expect(profile_json['id']).to equal(profile.id)
        expect(profile_json['observations_count'])
          .to equal(profile.observations_count)
        expect(profile_json['simulator_instance_id'])
          .to equal(profile.simulator_instance_id)
        profile.symmetry_groups.each do |symmetry_group|
          expect(profile_json['symmetry_groups'])
            .to include('id' => symmetry_group.id,
                        'role' => symmetry_group.role,
                        'strategy' => symmetry_group.strategy,
                        'count' => symmetry_group.count,
                        'payoff' => symmetry_group.payoff,
                        'payoff_sd' => symmetry_group.payoff_sd)
        end
      end

      it 'returns the json with adjusted payoffs when requested' do
        profile.symmetry_groups.update_all(adjusted_payoff: rand.to_f,
                                           adjusted_payoff_sd: rand.to_f)
        profile_json = MultiJson.load(
          presenter.to_json(granularity: 'summary', adjusted: true))
        profile.symmetry_groups.each do |symmetry_group|
          expect(profile_json['symmetry_groups'])
            .to include('id' => symmetry_group.id,
                        'role' => symmetry_group.role,
                        'strategy' => symmetry_group.strategy,
                        'count' => symmetry_group.count,
                        'payoff' => symmetry_group.adjusted_payoff,
                        'payoff_sd' => symmetry_group.adjusted_payoff_sd)
        end
      end
    end

    context 'when the granularity is observations' do
      it 'returns the expected json' do
        profile_json = MultiJson.load(
          presenter.to_json(granularity: 'observations'))
        expect(profile_json['id']).to equal(profile.id)
        expect(profile_json['simulator_instance_id'])
          .to equal(profile.simulator_instance_id)
        profile.symmetry_groups.each do |symmetry_group|
          expect(profile_json['symmetry_groups'])
            .to include('id' => symmetry_group.id,
                        'role' => symmetry_group.role,
                        'strategy' => symmetry_group.strategy,
                        'count' => symmetry_group.count)
        end
        profile.observations.each do |observation|
          obs = profile_json['observations'].find do |o|
            flag = true
            observation.observation_aggs.each do |agg|
              flag &&= o['symmetry_groups']
                .include?('id' => agg.symmetry_group_id,
                          'payoff' => agg.payoff, 'payoff_sd' => agg.payoff_sd)
            end
            flag && o['features'] == observation.features
          end
          expect(obs.nil?).to equal(false)
        end
      end

      it 'returns the json with adjusted payoffs when requested' do
        profile.symmetry_groups.each do |s|
          s.observation_aggs.update_all(adjusted_payoff: rand,
                                        adjusted_payoff_sd: rand)
        end
        profile_json = MultiJson.load(
          presenter.to_json(granularity: 'observations', adjusted: true))
        profile.observations.each do |observation|
          obs = profile_json['observations'].find do |o|
            flag = true
            observation.observation_aggs.each do |agg|
              flag &&= o['symmetry_groups']
                .include?('id' => agg.symmetry_group_id,
                          'payoff' => agg.adjusted_payoff,
                          'payoff_sd' => agg.adjusted_payoff_sd)
            end
          end
          expect(obs.nil?).to equal(false)
        end
      end
    end

    context 'when the granularity is full' do
      let(:response) do
        "{\"id\":#{profile.id},\"simulator_instance_id\":" \
        "#{profile.simulator_instance_id},\"symmetry_groups\":" +
        profile.symmetry_groups.map do |symmetry_group|
          { id: symmetry_group.id, role: symmetry_group.role,
            strategy: symmetry_group.strategy, count: symmetry_group.count
          }
        end.to_json + ",\"observations\":" +
        profile.observations.map do |observation|
          { features: observation.features,
            players: observation.players.map do |player|
              { symmetry_group_id: player.symmetry_group_id,
                payoff: 100, features: player.features }
            end }
        end.to_json + '}'
      end

      it 'returns the expected json' do
        profile_json = MultiJson.load(presenter.to_json(granularity: 'full'))
        expect(profile_json['id']).to equal(profile.id)
        expect(profile_json['simulator_instance_id'])
          .to equal(profile.simulator_instance_id)
        profile.symmetry_groups.each do |symmetry_group|
          expect(profile_json['symmetry_groups'])
            .to include('id' => symmetry_group.id,
                        'role' => symmetry_group.role,
                        'strategy' => symmetry_group.strategy,
                        'count' => symmetry_group.count)
        end
        profile.observations.each do |observation|
          obs = profile_json['observations'].find do |o|
            flag = true
            observation.players.each do |player|
              flag &&= o['players'].include?('sid' => player.symmetry_group_id,
                                             'p' => player.payoff,
                                             'f' => player.features,
                                             'e' => player.extended_features)
            end
            flag && o['features'] == observation.features
          end
          expect(obs.nil?).to equal(false)
        end
      end

      it 'returns the json with adjusted payoffs when requested' do
        Player.update_all(adjusted_payoff: rand)
        profile_json = MultiJson.load(presenter.to_json(
          granularity: 'full', adjusted: true))
        profile.observations.each do |observation|
          obs = profile_json['observations'].find do |o|
            flag = true
            observation.players.each do |player|
              flag &&= o['players'].include?('sid' => player.symmetry_group_id,
                                             'p' => player.adjusted_payoff,
                                             'f' => player.features,
                                             'e' => player.extended_features)
            end
          end
          expect(obs.nil?).to equal(false)
        end
      end
    end
  end
end
