class SimulationsController < AuthenticatedController
  expose(:simulations){ Simulation.joins(:profile).order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:simulation)
  
  private
  
  def default_order
    "id"
  end
end