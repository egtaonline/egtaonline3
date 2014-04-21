require 'spec_helper'

describe GamePresenter do
  let(:game) { create(:game, :with_strategies) }
  let!(:profile) do
    create(:profile, :with_observations,
           simulator_instance_id: game.simulator_instance_id,
           assignment: 'Role1: 2 A, 1 B; Role2: 2 C')
  end
  let!(:profile2) do
    create(:profile, :with_observations,
           simulator_instance_id: game.simulator_instance_id,
           assignment: 'Role1: 3 B; Role2: 2 C')
  end
  subject { GamePresenter.new(game) }

  describe '#to_json' do
    context 'when granularity is specified as summary' do
      it 'makes the correct json' do
        location = subject.to_json(granularity: 'summary')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile(json, profile, 'summary')
        validate_profile(json, profile2, 'summary')
      end

      it 'provides the adjusted data when requested' do
        profile.symmetry_groups.update_all(adjusted_payoff: rand,
                                           adjusted_payoff_sd: rand)
        profile2.symmetry_groups.update_all(adjusted_payoff: rand,
                                            adjusted_payoff_sd: rand)
        location = subject.to_json(granularity: 'summary', adjusted: true)
        json = MultiJson.load(File.open(location).read)
        validate_adjustments(json, profile, 'summary')
        validate_adjustments(json, profile2, 'summary')
      end
    end

    context 'when granularity is specified as observations' do
      it 'makes the correct json' do
        location = subject.to_json(granularity: 'observations')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile(json, profile, 'observations')
        validate_profile(json, profile2, 'observations')
      end

      it 'provides the adjusted data when requested' do
        [profile, profile2].each do |prof|
          prof.symmetry_groups.each do |s|
            s.observation_aggs.update_all(adjusted_payoff: rand,
                                          adjusted_payoff_sd: rand)
          end
        end
        [profile, profile2].each { |prof| prof.reload }
        location = subject.to_json(granularity: 'observations', adjusted: true)
        json = MultiJson.load(File.open(location).read)
        validate_adjustments(json, profile, 'observations')
        validate_adjustments(json, profile2, 'observations')
      end
    end

    context 'when granularity is specified as full granularity' do
      it 'makes the correct json' do
        location = subject.to_json(granularity: 'full')
        json = MultiJson.load(File.open(location).read)
        validate_basics(json, game)
        validate_profile(json, profile, 'full')
        validate_profile(json, profile2, 'full')
      end

      it 'provides the adjusted data when requested' do
        Player.update_all(adjusted_payoff: rand)
        [profile, profile2].each { |prof| prof.reload }
        location = subject.to_json(granularity: 'full', adjusted: true)
        json = MultiJson.load(File.open(location).read)
        validate_adjustments(json, profile, 'full')
        validate_adjustments(json, profile2, 'full')
      end
    end
  end

  private

  def validate_adjustments(json, profile, gran)
    p_json = json['profiles'].find { |p| p['id'] == profile.id }
    case gran
    when 'summary'
      symmetry_adjustments(p_json['symmetry_groups'], profile.symmetry_groups)
    when 'observations'
      observation_adjustments(p_json['observations'], profile.observations)
    when 'full'
      player_adjustments(p_json['observations'], profile.observations)
    end
  end

  def symmetry_adjustments(symmetry_json, symmetry_groups)
    symmetry_groups.each do |symmetry_group|
      test_map = { 'id' => symmetry_group.id, 'role' => symmetry_group.role,
                   'strategy' => symmetry_group.strategy,
                   'count' => symmetry_group.count,
                   'payoff' => symmetry_group.adjusted_payoff,
                   'payoff_sd' => symmetry_group.adjusted_payoff_sd }
      expect(symmetry_json).to include(test_map)
    end
  end

  def observation_adjustments(o_json, observations)
    observations.each do |observation|
      obs = o_json.find do |o|
        observation.observation_aggs.each do |agg|
          flag &&= o['symmetry_groups'].include?(
          'id' => agg.symmetry_group_id, 'payoff' => agg.adjusted_payoff,
          'payoff_sd' => agg.adjusted_payoff_sd)
        end
      end
      expect(obs.nil?).to equal(false)
    end
  end

  def player_adjustments(o_json, observations)
    observations.each do |observation|
      obs = o_json.find do |o|
        flag = o['features'] == observation.features
        observation.players.each do |player|
          flag &&= o['players'].include?(
            'sid' => player.symmetry_group_id, 'p' => player.adjusted_payoff,
            'f' => player.features, 'e' => player.extended_features)
        end
      end
      expect(obs.nil?).to equal(false)
    end
  end

  def validate_basics(json, game)
    expect(json['id']).to equal(game.id)
    expect(json['name']).to eq(game.name)
    expect(json['simulator_fullname']).to eq(game.simulator_fullname)
    expect(json['configuration'])
      .to eq(game.configuration.to_a.map { |e| [e[0], e[1].to_s] })
    expect(json['roles'])
      .to include('name' => 'Role1', 'strategies' => %w(A B),
                  'count' => 3)
    expect(json['roles']).to include('name' => 'Role2',
                                     'strategies' => %w(C D), 'count' => 2)
  end

  def validate_profile(json, profile, gran)
    profile_json = json['profiles'].find { |p| p['id'] == profile.id }
    profile.symmetry_groups.each do |symmetry_group|
      validate_symmetry_group(profile_json['symmetry_groups'],
                              symmetry_group, gran)
    end
    validate_observations(profile_json, profile, gran)
  end

  def validate_symmetry_group(json, symmetry_group, gran)
    test_map = { 'id' => symmetry_group.id, 'role' => symmetry_group.role,
                 'strategy' => symmetry_group.strategy,
                 'count' => symmetry_group.count }
    test_map = test_map.merge(
      'payoff' => symmetry_group.payoff,
      'payoff_sd' => symmetry_group.payoff_sd) if gran == 'summary'
    expect(json).to include(test_map)
  end

  def validate_observations(json, profile, gran)
    if gran == 'summary'
      expect(json['observations_count'])
        .to equal(profile.observations_count)
    else
      expect(json['observations'].size)
        .to equal(profile.observations_count)
      profile.observations.each do |observation|
        validate_observation(json['observations'], observation, gran)
      end
    end
  end

  def validate_observation(json, observation, gran)
    case gran
    when 'full'
      validate_full_observation(json, observation)
    when 'observation'
      validate_o_observation(json, observation)
    end
  end

  def validate_o_observation(json, observation)
    obs = json.find do |o|
      flag = o['features'] == observation.features
      observation.observation_aggs.each do |agg|
        flag &&= o['symmetry_groups'].include?('id' => agg.symmetry_group_id,
                                               'payoff' => agg.payoff,
                                               'payoff_sd' => agg.payoff_sd)
      end
    end
    expect(obs.nil?).to equal(false)
  end

  def validate_full_observation(json, observation)
    obs = json.find do |o|
      flag = o['features'] == observation.features
      observation.players.each do |player|
        flag &&= o['players'].include?(
          'sid' => player.symmetry_group_id, 'p' => player.payoff,
          'f' => player.features, 'e' => player.extended_features)
      end
    end
    expect(obs.nil?).to equal(false)
  end
end
