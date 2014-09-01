class GamesController < ProfileSpacesController

  helper_method :download_output

  expose(:games) do
    Game.includes(simulator_instance: :simulator)
    .order("#{sort_column} #{sort_direction}")
    .page(params[:page])
  end
  expose(:game, attributes: :game_parameters)  do
    id = params['game_id'] || params[:id]
    if id
      g = Game.find(id)
      if params[:action] == 'update'
        g.assign_attributes(game_parameters)
      end
      g
    elsif params[:game]
      GameBuilder.new_game(game_parameters, params[:selector][:simulator_id],
       params[:selector][:configuration])
    else
      Game.new
    end
  end
  expose(:role_owner) { game }
  expose(:role_owner_path) { "/games/#{game.id}" }
  expose(:profile_counts) { game.profile_counts }
  expose(:control_variate_statement) do
    control_variate_state = game.control_variate_state
    case control_variate_state.state
    when 'applying'
      'Currently applying control variates.'
    when 'complete'
      'Control variates applied at: ' \
      "#{control_variate_state.updated_at.localtime}"
    else
      'No applied control variates.'
    end
  end

  expose(:title) do
    game.name || 'EGTAOnline'
  end

  expose(:analysis_path) do
    "/analysis/#{game.id}"
  end

  def show
    respond_to do |format|
      format.html do
      end

      format.json do
        file_name = GamePresenter.new(game)
        .to_json(granularity: params[:granularity])
        send_file file_name, type: 'text/json'
      end
    end
  end

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
  def create_process
    
  end

  def analyze
    analysis = game.analyses.create(status: 'pending', enable_subgame: params[:enable_subgame] != nil, enable_reduction: params[:enable_reduced] != nil)
    analysis.create_analysis_script(verbose: params[:enable_verbose] != nil, regret: params[:regret], dist: params[:dist], converge: params[:converge], iters: params[:iters], points: params[:points], support: params[:support],enable_dominance: params[:enable_dominance] != nil)
    analysis.create_pbs(day: params[:day], hour: params[:hour], minute: params[:min], memory: params[:memory], memory_unit: params[:unit], user_email: "#{current_user.email}")
    
    if params[:enable_reduced] != nil
        role_number_array = Array.new
        game.roles.each do |role|
        role_number_array << params[role.name]
      end
      analysis.create_reduction_script(mode: params[:reduced_mode], reduced_number: role_number_array.join(" "))
    end

    AnalysisManager.new(analysis).prepare_analysis

  end

  private

  
  def game_parameters
    params.require(:game).permit(:name, :size, :simulator_instance_id)
  end


end

