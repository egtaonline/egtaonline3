class ControlVariateApplicator
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(sim_instance_id, control_variables, player_control_variables)
    simulator_instance = SimulatorInstance.find(sim_instance_id)
    simulator_instance.control_variate_state.update_attributes(
      state: 'applying')
    ControlVariateUpdater.update(control_variables, player_control_variables)
    # dumb way of ensuring against sql-injection since the rails way
    # doesn't seem to like the hstore commands
    instance_id = simulator_instance.id
    PlayerUpdater.update(instance_id)
    ObservationAggsUpdater.update(instance_id)
    SymmetryAdjPayoffUpdater.update(instance_id)
    simulator_instance.control_variate_state.update_attributes(
      state: 'complete')
  end
end
