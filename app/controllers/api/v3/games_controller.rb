class Api::V3::GamesController < Api::V3::BaseController
  before_filter :find_object, only: [:show, :edit, :destroy, :add_strategy]
  before_filter :find_role, only: [:add_strategy]
  before_filter :find_strategy, only: [:add_strategy]

  def add_strategy
    @object.add_strategy(params[:role], params[:strategy])
    render json: nil, status: 204
  end

  private

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