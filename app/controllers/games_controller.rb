
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
        # if(File.exist?("/mnt/nfs/home/egtaonline/analysis/#{game.id}/subgame/#{game.id}-subgame.json"))
        
        #debug
        if(File.exist?("#{Rails.root}/app/analysis/#{game.id}/subgame/#{game.id}-subgame.json"))
          # subgame_json = File.open("/mnt/nfs/home/egtaonline/analysis/#{game.id}/subgame/#game.id}-subgame.json", "rb")
          subgame_json = File.open("#{Rails.root}/app/analysis/#{game.id}/subgame/#{game.id}-subgame.json", "rb")

          game.subgames = subgame_json.read
          if game.save
            # FileUtils.rm "/mnt/nfs/home/egtaonline/analysis/#{game.id}/subgame/#game.id}-subgame.json"
            FileUtils.rm "#{Rails.root}/app/analysis/#{game.id}/subgame/#{game.id}-subgame.json"

          else
            flash[:alert] = game.errors.full_messages.first 
          end
        end
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

    analysis_obj = AnalysisArgumentSetter.new("-r #{params[:regret]} -d #{params[:dist]} -s #{params[:support]} -c #{params[:converge]}  -i #{params[:iters]}")
    
    if params[:enable_reduced] != nil
      reduced_num_array = Array.new  
      game.roles.each do |role|
        reduced_num_array << params["#{role.name}"]
      end
      reduction_obj = ReducedArgumentSetter.new(params[:reduced_mode], reduced_num_array)
    end
    
    if params[:enable_subgame] != nil
      subgame_obj = SubgameArgumentSetter.new
    end


    scripts_argument_setter_obj = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,subgame_obj)
    pbs_formatter_obj = AnalysisPbsFormatter.new("#{current_user.email}",params[:day], params[:hour], params[:min])
    
    analysis = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)

    analysis.launch_analysis
    @time = analysis.time
  end

  private

  
  def game_parameters
    params.require(:game).permit(:name, :size, :simulator_instance_id)
  end


end

