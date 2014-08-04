
require_relative 'analysis_path_finder.rb'
require_relative 'scripts_argument_setter.rb'
require_relative  'analysis_pbs_formatter.rb'
require_relative 'analysis_submitter'

class AnalysisManager 
  attr_reader :time
  # def initialize(game_id,enable_reduced,analysis_hash,reduced_num_array,roles_count,reduced_mode, email, day, hour, min)
  def initialize(game_id,enable_reduced,regret,dist,support,converge,iters,reduced_num_array,roles_count,reduced_mode, email, day, hour, min)


    @reduced_mode = reduced_mode
    @time = Time.now.strftime('%Y%d%m%H%M%S%Z')
    @game_id = game_id
    @enable_reduced = enable_reduced

    @regret = regret
    @dist = dist
    @support = support
    @converge = converge
    @iters = iters
    @reduced_num_array = reduced_num_array
    @roles_count = roles_count
    @email = email
    @path_finder = AnalysisPathFinder.new(@game_id, @time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    
    ###For Debug######
    # @path_finder = AnalysisPathFinder.new(@game_id, @time, "#{Rails.root}/app","/nfs/wellman_ls")

    
    hours = hour.to_i + day.to_i * 24
    @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',min)}:00"
  end

  def prepare_data
    FileUtils::mkdir_p "#{@path_finder.local_output_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_input_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_pbs_path}", mode: 0770
    # FileUtils.mv("#{GamePresenter.new(Game.find(@game_id)).to_json()}",File.join("#{@path_finder.local_input_path}","#{@path_finder.input_file_name}"), mode: 0755)
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
 
end
