class SimulationsController < AuthenticatedController
  expose(:simulations) do
    Simulation.joins(:profile).order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end
  expose(:simulation)

  private

  def default_order
    'id'
  end
end
