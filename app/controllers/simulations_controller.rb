class SimulationsController < AuthenticatedController
  expose(:simulations) do
    if params[:search]
      Simulation.joins(profile: :simulator_instance).search(params[:search])
        .order("#{sort_column} #{sort_direction}").page(params[:page])
    else
      Simulation.joins(profile: :simulator_instance).order("#{sort_column} #{sort_direction}")
        .page(params[:page])
    end
  end
  expose(:simulation)

  def index
    @default_search_column = "Profile"
  end

  private

  def default_order
    'id'
  end
end
