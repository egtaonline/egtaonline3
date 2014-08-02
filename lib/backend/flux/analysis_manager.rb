
require_relative 'analysis_path_finder.rb'
require_relative 'scripts_argument_setter.rb'
require_relative  'analysis_pbs_formatter.rb'
require_relative 'analysis_submitter'

class AnalysisManager 
  attr_reader :time
  # def initialize(game_id,enable_reduced,analysis_hash,reduced_num_array,roles_count,reduced_mode, email, day, hour, min)
  def initialize(game_id,enable_reduced,regret,dist,support,converge,iters,reduced_num_array,roles_count,reduced_mode, email, day, hour, min)

    # local_data_path, remote_data_path, time, game_id)
    # @local_data_path = options[:local_data_path]
    # @remote_data_path = options[:remote_data_path]
    @reduced_mode = reduced_mode
    @time = Time.now.strftime('%Y%d%m%H%M%S%Z')
    @game_id = game_id
    @enable_reduced = enable_reduced
    # @analysis_hash = analysis_hash
    @regret = regret
    @dist = dist
    @support = support
    @converge = converge
    @iters = iters
    @reduced_num_array = reduced_num_array
    @roles_count = roles_count
    @email = email
    @path_finder = AnalysisPathFinder.new(@game_id, @time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    # @path_finder = AnalysisPathFinder.new(@game_id, @time, "#{Rails.root}/app","#{Rails.root}/public")
    
    hours = hour.to_i + day.to_i * 24
    @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',min)}:00"
  end

  def prepare_data
    FileUtils::mkdir_p "#{@path_finder.local_output_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_input_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_pbs_path}", mode: 0770
    FileUtils.mv("#{GamePresenter.new(Game.find(@game_id)).to_json()}" ,File.join("#{@path_finder.local_input_path}","#{@path_finder.input_file_name}"))
  end

  def set_script_arguments
    @running_script_command = ScriptsArgumentSetter.scriptCommand(@enable_reduced,@reduced_num_array, @roles_count,@reduced_mode,@path_finder, @regret, @dist, @support, @converge, @iters)
  end

  def create_pbs
     @pbs = AnalysisPbsFormatter.new(@path_finder, @running_script_command,@email, @walltime).write_pbs
  end
  def submit_job
    AnalysisSubmitter.submit(File.join("#{@path_finder.remote_pbs_path}","#{@path_finder.pbs_file_name}"))
  end

  def clean
    
  end
    # def analyze
    # @reduced = params[:enable_reduced] 
    # if @reduced != nil end
    #   @reduced_script_AnalysisArgumentSetterarg = reduced_script_arg(@game.roles,params[:reduced_mode])
    # end
    # @time = Time.now.strftime('%Y%d%m%H%M%S%Z')
    # @local_path = "/mnt/nfs/home/egtaonline"
    # @local_path = "#{Rails.root}"
    
    # @local_data_path = "#{@local_path}/analysis/#{game.id}"
    # @remote_path = "/nfs/wellman_ls/egtaonline/analysis/#{game.id}"


    ######Set Reduced Script Arguments###########
    

    ###############################################

    ######Set Analysis Script Arguments############



    #######################################

    #######Write PBS script and submit the job##############
  
  

    ###########################################################
 
end
