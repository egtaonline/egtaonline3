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
        #create folder if it doesn't exist, move everything in the output folder 
        FileUtils::mkdir_p "#{Rails.root}/public/analysis/#{game.id}"
        FileUtils.cp_r(Dir["/mnt/nfs/home/egtaonline/analysis/#{game.id}/out/*"],"#{Rails.root}/public/analysis/#{game.id}")
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
    analysis_argument = params.select {|key, value| [:regret, :dist, :support, :converge, :iters].include?(key) }
    #could pass the whole hash and join values together, revise later
    reduced_num_array = Array.new  
    if params[:enable_reduced] != nil
      game.roles.each do |role|
        reduced_num_array << params["#{role.name}"]
      end
    end
    #no need to pass enable_reduced, revise later
    #not sure if initialization works
    analysis = AnalysisManager.new(game.id.to_s,params[:enable_reduced],analysis_argument,reduced_num_array,game.roles.count, params[:reduced_mode],"#{current_user.email}",params[:day], params[:hour], params[:min])
    @time = analysis.time
    analysis.prepare_data
    analysis.set_script_arguments
    analysis.create_pbs
    analysis.submit_job

  end

  private

  
    def game_parameters
      params.require(:game).permit(:name, :size, :simulator_instance_id)
    end


end

