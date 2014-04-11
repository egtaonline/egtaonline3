class Api::V3::GamesController < Api::V3::BaseController
  include Api::V3::RoleManipulator
  include Api::V3::StrategyManipulator

  before_filter :find_object, only: [
    :show, :add_strategy, :remove_strategy, :add_role, :remove_role]
  before_filter :find_role, only: [:add_strategy, :remove_strategy]
  before_filter :find_strategy, only: [:add_strategy]
  before_filter :role_exists, only: :add_role

  def index
    render json: { games: Game.all }, status: 200
  end

  def show
    render json: GamePresenter.new(@object)
             .to_json(granularity: params[:granularity]),
           status: 200
  end

  private

  def find_role
    @role = @object.roles.find_by(name: params[:role])
    unless @role
      respond_with({ error: 'the Role you were looking for could not' \
                       ' be found' },
                     status: 422, location: nil)
    end
  end

  def find_strategy
    unless @object.simulator.role_configuration[@role.name].include?(
      params[:strategy])
      respond_with({ error: 'the Strategy you wished to add was not found' +
        " on the Game's Simulator" }, status: 422, location: nil)
    end
  end
end
