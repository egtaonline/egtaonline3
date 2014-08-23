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
        orgin_path = "/mnt/nfs/home/egtaonline/analysis/#{game.id}"
        
        #DEBUG##########################
        # orgin_path = "#{Rails.root}/app/analysis/#{game.id}"

        dest_path = "#{Rails.root}/public/analysis/#{game.id}" 
        #create folder if it doesn't exist, move everything in the output folder 
        FileUtils::mkdir_p dest_path
        FileUtils.mv(Dir["#{orgin_path}/out/*"],dest_path)
       
        # move error files 
        Dir["#{orgin_path}/pbs/*.e"].each do |error_file|         
            FileUtils.cp_r("#{error_file}", dest_path) unless File.zero?(error_file)             
            FileUtils.rm error_file
        end
        
        if(File.exist?("#{orgin_path}/subgame/#{game.id}-subgame.json"))
          if File.zero?("#{orgin_path}/subgame/#{game.id}-subgame.json")
            FileUtils.rm "#{orgin_path}/subgame/#{game.id}-subgame.json" 
          else
            subgame_json = File.open("#{orgin_path}/subgame/#{game.id}-subgame.json", "rb")
            game.subgames = subgame_json.read        
            flash[:alert] = game.errors.full_messages.first unless game.save                      
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
    analysis = game.analyses.create(enable_subgame: params[:enable_subgame] != nil, enable_reduction: params[:enable_reduced] != nil)
    analysis.create_analysis_script(verbose: params[:enable_verbose] != nil, regret: params[:regret], dist: params[:dist], converge: params[:converge], iters: params[:iters], points: params[:points], enable_dominance: params[:enable_dominance] != nil)
    analysis.create_pbs(day: params[:day], hour: params[:hour], minute: params[:min], memory: params[:memory], memory_unit: params[:unit], user_email: "#{current_user.email}")
    
    if params[:enable_reduced] != nil
        role_number_array = Array.new
        game.roles.each do |role|
        role_number_array << params[role.name]
      end
      analysis.create_reduction_script(mode: params[:reduced_mode], reduced_number: role_number_array.join(" "))
    end


    @path_obj = AnalysisPathFinder.new(game.id.to_s, analysis.id.to_s, "#{Rails.root}/app","/nfs/wellman_ls")
    AnalysisManager.new(analysis, game).prepare_analysis
    # AnalysisPbsFormatter.new("#{current_user.email}",params[:day], params[:hour], params[:min], params[:memory], params[:unit])

    # scripts_argument_setter_obj = ScriptsArgumentSetter.new(analysis)
  end
  #   if params[:enable_verbose] !=nil 
  #     analysis_obj = AnalysisArgumentSetter.new("-r #{params[:regret]} -d #{params[:dist]} -s #{params[:support]} -c #{params[:converge]}  -i #{params[:iters]} -p #{params[:points]} --verbose")
  #   else
  #     analysis_obj = AnalysisArgumentSetter.new("-r #{params[:regret]} -d #{params[:dist]} -s #{params[:support]} -c #{params[:converge]}  -i #{params[:iters]} -p #{params[:points]}")
  #   end
    
  #   if params[:enable_reduced] != nil
  #     reduced_num_array = Array.new  
  #     game.roles.each do |role|
  #       reduced_num_array << params["#{role.name}"]
  #     end
  #     reduction_obj = ReducedArgumentSetter.new(params[:reduced_mode], reduced_num_array)
  #   end
    
  #   if params[:enable_subgame] != nil
  #     subgame_obj = SubgameArgumentSetter.new
  #   end


  #   
    
  #   analysis = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)


  #   response = analysis.launch_analysis
  #   unless response =~ /\A(\d+)/ 
  #     flash[:flux_error] = "Submission failed: #{response}" 
  #   end

  #   @time = analysis.time
  # end

  private

  def game_parameters
    params.require(:game).permit(:name, :size, :simulator_instance_id)
  end


end

