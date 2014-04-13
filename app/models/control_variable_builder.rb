class ControlVariableBuilder
  def initialize(simulator_instance)
    @simulator_instance = simulator_instance
    @observed_cvs = []
    @observed_player_cvs = Hash.new { |hash, key| hash[key] = [] }
  end

  def extract_control_variables(data)
    sim_instance_id = @simulator_instance.id
    new_cvs(data['features'].keys).each do |k|
      ControlVariable.find_or_create_by(
        name: k, simulator_instance_id: sim_instance_id)
    end
    key_map = Hash.new { |hash, key| hash[key] = [] }
    data['symmetry_groups'].each do |sgroup|
      role = sgroup['role']
      keys = sgroup['players'].map do |player|
        player['features'].keys
      end.flatten
      key_map[role] = key_map[role] + keys
    end
    new_player_cvs(key_map).each do |role, names|
      names.each do |name|
        PlayerControlVariable.find_or_create_by(
          name: name, simulator_instance_id: sim_instance_id, role: role)
      end
    end
  end

  private

  def new_cvs(keys)
    keys = keys.uniq
    new_keys = keys - @observed_cvs
    @observed_cvs += new_keys
    new_keys
  end

  def new_player_cvs(key_map)
    new_key_map = Hash.new { |hash, key| hash[key] = [] }
    key_map.each do |key, value|
      new_key_map[key] = value.uniq - @observed_player_cvs[key]
      @observed_player_cvs[key] = @observed_player_cvs[key] + new_key_map[key]
    end
    new_key_map
  end
end
