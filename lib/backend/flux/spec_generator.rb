require 'multi_json'

class SpecGenerator
  def initialize(local_path)
    @path = local_path
  end

  def generate(simulation)
    spec = {}
    profile = simulation.profile
    spec["assignment"] = Hash.new{ |hash, key| hash[key] = [] }
    simulation.profile.symmetry_groups.each do |symmetry_group|
      symmetry_group.count.times do
        spec["assignment"][symmetry_group.role] << symmetry_group.strategy
      end
    end
    spec["configuration"] = profile.simulator_instance.configuration
    file = File.open("#{@path}/#{simulation.id}/simulation_spec.json",
      'w') do |f|
        f.write(MultiJson.dump(spec))
    end
  end
end