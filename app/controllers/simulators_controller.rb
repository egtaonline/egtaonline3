class SimulatorsController < AuthenticatedController
  expose(:simulators)
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
