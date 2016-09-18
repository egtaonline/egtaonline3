class SimulationsController < AuthenticatedController
  expose(:simulations) do
    if params[:search]
      Simulation.search(params[:search]).joins(profile: :simulator_instance)
        .order("#{sort_column} #{sort_direction}").page(params[:page])
    else
      Simulation.joins(profile: :simulator_instance).order("#{sort_column} #{sort_direction}")
        .page(params[:page])
    end
  end
  expose(:simulation)

  private

  def default_order
    'id'
  end
end
