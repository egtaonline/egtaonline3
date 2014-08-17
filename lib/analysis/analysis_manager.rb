require_relative 'analysis_path_finder.rb'
require_relative 'scripts_argument_setter.rb'
require_relative  'analysis_pbs_formatter.rb'

class AnalysisManager 
  attr_reader :time
  def initialize(game, scripts_argument_setter_obj, pbs_formatter_obj)
    @game = game
    @time = Time.now.strftime('%Y%d%m%H%M%S%Z')
    @scripts_argument_setter_obj = scripts_argument_setter_obj
    @pbs_formatter_obj = pbs_formatter_obj
    @game_id = game.id.to_s
    @path_finder = AnalysisPathFinder.new(@game_id, @time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    
    ###For Local Debug######
    # @path_finder = AnalysisPathFinder.new(@game_id, @time, "#{Rails.root}/app","/nfs/wellman_ls")
    
    @scripts_argument_setter_obj.set_path(@path_finder) 
  end

  def launch_analysis
    created_folder
    prepare_input
    set_script_arguments
    submit_job
  end

  private

  def created_folder
    FileUtils::mkdir_p "#{@path_finder.local_output_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_input_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_pbs_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_finder.local_subgame_path}", mode: 0770
  end

  def prepare_input
    @scripts_argument_setter_obj.prepare_input(@game)
  end 
                                                                                                                                                                                                                                                                                                                                                                                                                                    
  def set_script_arguments
    @set_up_remote_command = @scripts_argument_setter_obj.set_up_remote_command
    @running_script_command = @scripts_argument_setter_obj.get_script_command
    @clean_up_command = @scripts_argument_setter_obj.clean_up_remote_command
  end

  def submit_job
    pbs_file = @pbs_formatter_obj.prepare_pbs(File.join(@path_finder.remote_pbs_path, @path_finder.pbs_error_file), File.join(@path_finder.remote_pbs_path,@path_finder.pbs_output_file), @set_up_remote_command, @running_script_command, @clean_up_command)
    @pbs_formatter_obj.write_pbs(pbs_file, File.join("#{@path_finder.local_pbs_path}","#{@path_finder.pbs_file_name}"))
    
    ####Comment with no access to flux
    @pbs_formatter_obj.submit(File.join("#{@path_finder.remote_pbs_path}","#{@path_finder.pbs_file_name}"))
  end 
end
