class Api::V3::SimulatorsController < Api::V3::BaseController
  include Api::V3::StrategyManipulator
  before_filter :find_object, only: [
    :show, :add_strategy, :remove_strategy, :add_role, :remove_role]
  before_filter :find_role, only: [:add_strategy, :remove_strategy]

  def index
    render json: { simulators: Simulator.all }, status: 200
  end

  def show
    respond_with(@object)
  end

  def add_role
    if @object.add_role(params[:role])
      render json: nil, status: 204, location: nil
    else
      respond_with({ error: 'only letters, numbers, or' +
        ' underscores are allowed in Role name' }, status: 422, location: nil)
    end
  end

  def remove_role
    @object.remove_role(params[:role])
    render json: nil, status: 204
  end

  private

  def find_role
    unless @object.role_configuration[params[:role]]
      respond_with({ error: 'the Role you were looking for could not' +
        ' be found' }, status: 422, location: nil)
    end
  end
end
