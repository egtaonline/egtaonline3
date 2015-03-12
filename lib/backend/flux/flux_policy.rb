class FluxPolicy
  def initialize(flux_active_limit)
    @flux_active_limit = flux_active_limit
  end

  def assign_queue(simulation)
    # cac_count = Simulation.active_on_other.count
    # flux_available = Simulation.active_on_flux.count - @flux_active_limit
    # if  4 * cac_count > (flux_available) || cac_count > 100
    #   simulation.update_attributes(qos: 'flux')
    # else
    #   simulation.update_attributes(qos: 'engin_flux')
    # end
    simulation.update_attributes(qos: 'flux')
    simulation
  end
end
