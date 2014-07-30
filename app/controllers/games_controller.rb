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
   
    "analysis/#{game.id}"
  end

  def show
    respond_to do |format|
      format.html do
        #create folder if it doesn't exist, move everything in the output folder 
        FileUtils::mkdir_p "#{Rails.root}/analysis/#{game.id}"
        FileUtils.cp_r(Dir["/mnt/nfs/home/egtaonline/analysis/#{game.id}/out/*"],"#{Rails.root}/analysis/#{game.id}")
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
    @time = Time.now.strftime('%Y%d%m%H%M%S%Z')
    @game = Game.find(params[:id])

    @local_path = "/mnt/nfs/home/egtaonline"
    # @local_path = "#{Rails.root}"
    FileUtils::mkdir_p "#{@local_path}/analysis/#{game.id}/out"
    FileUtils::mkdir_p "#{@local_path}/analysis/#{game.id}/in"
    @local_data_path = "#{@local_path}/analysis/#{game.id}"
    @remote_path = "/nfs/wellman_ls/egtaonline/analysis/#{game.id}"


    move_input_file

    ######Set Reduced Script Arguments###########
    @reduced = params[:enable_reduced] 
    if @reduced != nil 
      @reduced_script_arg = reduced_script_arg(@game.roles,params[:reduced_mode])
    end

    ###############################################

    ######Set Analysis Script Arguments############

    @analysis_script_arg = "-r #{params[:regret]} -d #{params[:dist]} -s #{params[:support]} -c  #{params[:converge]} -i #{params[:iters]}"


    #######################################

    #######Write PBS script and submit the job##############
    @document = run_pbs
    
    File.open("#{@local_data_path}/wrapper", 'w') do |f|
      f.write(@document)
    end

    proxy = Backend.connection.acquire
    
    if proxy
      begin
        response = proxy.exec!("qsub -V -r n #{@remote_path}/wrapper")       
          flash[:alert] = "Submission failed: #{response}" unless response =~ /\A(\d+)/
      rescue => e
          flash[:alert] = "Submission failed: #{e}"
      end
    end

    ###########################################################
  end
  

  private

  def move_input_file
     FileUtils.mv("#{GamePresenter.new(game).to_json()}","#{@local_data_path}/in/#{game.id}-analysis-#{@time}.json")
  end
  
  def reduced_script_arg(roles, mode)
      @reduced_argument = mode
      roles.each do |role|
        @reduced_argument = @reduced_argument + " " + params["#{role.name}"]
      end
      @reduced_argument
  end

  def run_pbs
      <<-DOCUMENT
      #!/bin/bash
      #PBS -N analysis

      #PBS -A wellman_flux
      #PBS -q flux
      #PBS -l qos=flux
      #PBS -W group_list=wellman

      #PBS -l walltime=0:10:00
      #PBS -l nodes=1:ppn=1,pmem=4000mb

      #PBS -M #{current_user.email}
      #PBS -m abe
      #PBS -V
      #PBS -W umask=0007

      umask 0007

      module load python/2.7.5

      mkdir /tmp/${PBS_JOBID}
      cp -r #{@remote_path}/in/#{@game.id}-analysis-#{@time}.json /tmp/${PBS_JOBID}
      cp -r /nfs/wellman_ls/GameAnalysis/Reductions.py /tmp/${PBS_JOBID}
      cp -r /nfs/wellman_ls/GameAnalysis/scripts/AnalysisScript.py /tmp/${PBS_JOBID}
      cd /tmp/${PBS_JOBID}

      export PYTHONPATH=$PYTHONPATH:/nfs/wellman_ls/GameAnalysis
      $mode="#{@reduced}"
      $enable="enable_reduced"
      if [ "$mode" == "$enable" ]; then
        python Reductions.py -input #{@game.id}-analysis-#{@time}.json -output #{@game.id}-reduced-#{@time}.json #{@reduced_script_arg}
        python AnalysisScript.py #{@analysis_script_arg} #{@game.id}-reduced-#{@time}.json > #{@game.id}-analysis-#{@time}.out
      else
        python AnalysisScript.py #{@analysis_script_arg} #{@game.id}-analysis-#{@time}.json > #{@game.id}-analysis-#{@time}.out
      fi      
        
      cp -r /tmp/${PBS_JOBID}/#{@game.id}-analysis-#{@time}.out #{@remote_path}/out
      rm -rf /tmp/${PBS_JOBID}
      DOCUMENT
    end

    def game_parameters
      params.require(:game).permit(:name, :size, :simulator_instance_id)
    end


end

