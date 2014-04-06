class ControlVariableBuilder
  def initialize(simulator_instance)
    @simulator_instance = simulator_instance
    @observed_cvs = []
    @observed_player_cvs = []
  end

  def extract_control_variables(data)
    sim_instance_id = @simulator_instance.id
    cvs_to_add(@observed_cvs, data["features"].keys).each { |k| ControlVariable.find_or_create_by(name: k, simulator_instance_id: sim_instance_id) }
    keys = data["symmetry_groups"].collect do |sgroup|
      sgroup["players"].collect do |player|
        player["features"].keys
      end.flatten
    end.flatten
    cvs_to_add(@observed_player_cvs, keys).each { |k| PlayerControlVariable.find_or_create_by(name: k, simulator_instance_id: sim_instance_id) }
  end

  private

  def cvs_to_add(old_keys, keys)
    keys = keys.uniq
    new_keys = keys - old_keys
    old_keys += new_keys
    new_keys
  end
end