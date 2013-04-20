class SimulatorsController < AuthenticatedController
  expose(:simulators){ Simulator.order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:simulator)

  def create
    simulator.save
    respond_with(simulator)
  end

  def update
    simulator.save
    respond_with(simulator)
  end

  def destroy
    simulator.destroy
    respond_with(simulator)
  end
end
