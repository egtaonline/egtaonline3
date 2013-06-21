class GamesController < ProfileSpacesController
  expose(:games){ Game.includes(:simulator_instance).order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:game, attributes: :game_parameters)
  expose(:role_owner){ game }
  expose(:role_owner_path){ "/games/#{game.id}" }
  expose(:profile_count){ game.profile_count }
  expose(:observation_count){ game.observation_count }

  def show
    respond_to do |format|
      format.html
      format.json { send_data GamePresenter.new(game).to_json(granularity: params[:granularity]), type: 'text/json', filename: "#{game.id}.json" }
    end
  end

  def create
    @game = GameFactory.create(game_parameters, params[:selector][:simulator_id], params[:selector][:configuration])
    respond_with(@game)
  end

  def update
    game.save
    respond_with(game)
  end

  def destroy
    game.destroy
    respond_with(game)
  end

  private

  def game_parameters
    params.require(:game).permit(:name, :size, :simulator_instance_id)
  end
end