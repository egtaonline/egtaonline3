class FluxPolicy
  def initialize(flux_active_limit)
    @flux_active_limit = flux_active_limit
  end

  def set_queue(simulation)
    cac_count = Simulation.active_on_other.count
    if ( 4*cac_count > (Simulation.active_on_flux.count-@flux_active_limit) || cac_count > 50)
      simulation.update_attributes(qos: 'flux')
    end
    simulation
  end
end
