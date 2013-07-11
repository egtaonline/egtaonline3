class Api::V3::GamesController < Api::V3::BaseController
  before_filter :find_object, only: [:show, :edit, :add_strategy,
    :remove_strategy, :add_role, :remove_role]
  before_filter :find_role, only: [:add_strategy, :remove_strategy]
  before_filter :find_strategy, only: [:add_strategy]
  before_filter :role_exists, only: :add_role

  def index
    render json: {games: Game.all}, status: 200
  end

  def show
    render json: GamePresenter.new(@object).to_json(
      granularity: params[:granularity]), status: 200
  end

  def add_role
    role = @object.add_role(params[:role], params[:count])
    respond_with(role, status: (role.valid? ? 204 : 422), location: nil)
  end

  def remove_role
    @object.remove_role(params[:role])
    render json: nil, status: 204
  end

  def add_strategy
    @object.add_strategy(params[:role], params[:strategy])
    render json: nil, status: 204
  end

  def remove_strategy
    @object.remove_strategy(params[:role], params[:strategy])
    render json: nil, status: 204
  end

  private

  def role_exists
    unless @object.simulator.role_configuration[params[:role]]
      respond_with({ error: "the Role you wished to add was not found" +
        " on the Game's Simulator"}, status: 424, location: nil)
    end
  end

  def find_role
    @role = @object.roles.find_by(name: params[:role])
    unless @role
      respond_with({ error: "the Role you were looking for could not" +
        " be found" }, status: 424, location: nil)
    end
  end

  def find_strategy
    unless @object.simulator.role_configuration[@role.name].include?(
      params[:strategy])
      respond_with({ error: "the Strategy you wished to add was not found" +
        " on the Game's Simulator"}, status: 424, location: nil)
    end
  end
end