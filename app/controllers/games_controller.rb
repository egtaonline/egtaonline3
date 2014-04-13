class GamesController < ProfileSpacesController
  expose(:games) do
    Game.includes(simulator_instance: :simulator)
      .order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end
  expose(:game, attributes: :game_parameters)
  expose(:role_owner) { game }
  expose(:role_owner_path) { "/games/#{game.id}" }
  expose(:profile_counts) { game.profile_counts }

  def show
    respond_to do |format|
      format.html
      format.json do
        file_name = GamePresenter.new(game)
          .to_json(granularity: params[:granularity])
        send_file file_name, type: 'text/json'
      end
    end
  end

  def create
    @game = GameBuilder.create(game_parameters,
                               params[:selector][:simulator_id],
                               params[:selector][:configuration])
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
