class GamesController < ProfileSpacesController
  expose(:games){ Game.order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:game)
  expose(:role_owner){ game }
  expose(:role_owner_path){ "/games/#{game.id}" }
  expose(:profile_count){ game.profile_count }
  expose(:observation_count){ game.observation_count }
  
  def create
    game.save
    respond_with(game)
  end

  def update
    game.save
    respond_with(game)
  end

  def destroy
    game.destroy
    respond_with(game)
  end
end