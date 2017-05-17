class GamesController < ProfileSpacesController

  helper_method :download_output

  expose(:games) do
    if params[:search]
      Game.includes(simulator_instance: :simulator).search(params[:search])
      .order("#{sort_column} #{sort_direction}")
      .page(params[:page])
    else
      Game.includes(simulator_instance: :simulator)
      .order("#{sort_column} #{sort_direction}")
      .page(params[:page])
    end
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

  def index
    @default_search_column = "Name"
  end

  def create_process
    #last_analysis = game.analyses.last 
    last_analysis = game.analyses.where(enable_learning: false).last

    if last_analysis != nil
      @pbs = last_analysis.pbs     
      @analysis_argument = last_analysis.analysis_script
      @enable_reduced = last_analysis.enable_reduction
      @enable_subgame = last_analysis.enable_subgame

      if @enable_reduced
        @reduction_argument = last_analysis.reduction_script
      end
    else
      @enable_reduced = true
      @enable_subgame = true
    end

    set_pbs_default
    set_analysis_default
    set_reduction_default
  end

  def create_learning_process
    #last_analysis = game.analyses.last
    last_analysis = game.analyses.where(enable_learning: true).last

    if last_analysis != nil
      @pbs = last_analysis.pbs
      @analysis_argument = last_analysis.learning_script
    end

    set_pbs_default
    set_learning_default
    # Don't need set_reduction_default
  end

  def analyze
    analysis = game.analyses.create(status: 'pending', enable_subgame: params[:enable_subgame] != nil, enable_reduction: params[:enable_reduced] != nil, enable_learning: false)
    analysis.create_analysis_script(verbose: params[:enable_verbose] != nil, regret: params[:regret], dist: params[:dist], converge: params[:converge], iters: params[:iters], points: params[:points], support: params[:support],enable_dominance: params[:enable_dominance] != nil)
    analysis.create_pbs(day: params[:day], hour: params[:hour], minute: params[:min], memory: params[:memory], memory_unit: params[:unit], user_email: "#{current_user.email}")
  
    if params[:enable_reduced] != nil       
        role_number_array = Array.new
        role_name_array = Array.new
        game.roles.each do |role|
        role_number_array << params[role.name]
        role_name_array << role.name
      end
      analysis.create_reduction_script(mode: params[:reduced_mode], reduced_number: role_name_array.zip(role_number_array).flatten.compact.join(" "))
    #reduced_number: role_number_array.join(" ")
    end
    AnalysisManager.new(analysis).prepare_analysis
    @analysis_id = analysis.id
  end

  def analyze_learning
    analysis = game.analyses.create(status: 'pending', enable_subgame: false, enable_reduction: false, enable_learning: true)
    analysis.create_learning_script(verbose: params[:enable_verbose] != nil, regret: params[:regret], dist: params[:dist], converge: params[:converge], iters: params[:iters], points: params[:points], support: params[:support],enable_dominance: params[:enable_dominance] != nil)
    analysis.create_pbs(day: params[:day], hour: params[:hour], minute: params[:min], memory: params[:memory], memory_unit: params[:unit], user_email: "#{current_user.email}")
    
    AnalysisManager.new(analysis).prepare_analysis
    @analysis_id = analysis.id
  end

  private

  def set_pbs_default
    if @pbs != nil
      @day = @pbs.day
      @hour = @pbs.hour
      @minute = @pbs.minute
      @memory = @pbs.memory
      @memory_unit = @pbs.memory_unit
    else
      @day = 0
      @hour = 6
      @minute = 0
      @memory = 4000
      @memory_unit = "mb"
    end
  end

  def set_analysis_default
    if @analysis_argument != nil
      @enable_verbose = @analysis_argument.verbose
      @regret = @analysis_argument.regret
      @dist = @analysis_argument.dist
      @converge =  @analysis_argument.converge
      @iters = @analysis_argument.iters
      @points = @analysis_argument.points
      @support = @analysis_argument.support
      @enable_dominance = @analysis_argument.enable_dominance
    else
      @enable_verbose = true
      @regret = 0.001
      @dist = 0.001
      @converge =  0.00000001
      @iters = 10000
      @points = 0
      @support = 0.001
      @enable_dominance = true
    end
  end
  
  def set_reduction_default
    @mode_hash = {"DPR" =>false, "HR" =>false}
    if @reduction_argument != nil
        role_name_array = Array.new
        game.roles.each do |role|
          role_name_array << role.name
        end
        role_number_array = @reduction_argument.reduced_number.split(" ").map { |s| s.to_i }.select.with_index { |_, j| j.odd? }
        @role_number_hash = Hash[role_name_array.zip role_number_array]
        @mode_hash[@reduction_argument.mode] = true
    else
        @role_number_hash = {}
        game.roles.each do |role|
          @role_number_hash[role.name] = role.count
        end
        @mode_hash["DPR"] = true
    end
  end

  def set_learning_default
    if @analysis_argument != nil
      @enable_verbose = @analysis_argument.verbose
      @regret = @analysis_argument.regret
      @dist = @analysis_argument.dist
      @converge =  @analysis_argument.converge
      @iters = @analysis_argument.iters
      @points = @analysis_argument.points
      @support = @analysis_argument.support
    else
      @enable_verbose = true
      @regret = 0.001
      @dist = 0.001
      @converge =  0.00000001
      @iters = 10000
      @points = 0
      @support = 0.001
    end
  end

  def game_parameters
    params.require(:game).permit(:name, :size, :simulator_instance_id)
  end


end

