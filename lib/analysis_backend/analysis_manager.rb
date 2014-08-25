require_relative 'command_setter.rb'
require_relative  'analysis_pbs_formatter.rb'
require_relative 'file_manager.rb'
require_relative 'reduced_script_setter.rb'
require_relative 'analysis_script_setter.rb'
require_relative 'subgame_setter.rb'
require_relative 'analysis_path_finder.rb'
require_relative 'dominance_script_setter.rb'


class AnalysisManager 
  def initialize(analysis, game)
    # @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "#{Rails.root}/app","/nfs/wellman_ls")
    @analysis = analysis
    @game = game
    @file_manager = FileManager.new(@path_finder)

  end

  def prepare_analysis
    prepare_files
    create_script_setters
    set_commands
    prepare_pbs
  end

  private

  def prepare_files
    @file_manager.created_folder
    @file_manager.prepare_analysis_input(@game)   
    if @analysis.enable_subgame 
      prepare_subgame
    end
  end

  def create_script_setters
    analysis_obj = AnalysisScriptSetter.new(@analysis.analysis_script, @path_finder)
    if @analysis.enable_reduction
      reduction_obj = ReducedScriptSetter.new(@analysis.reduction_script)
    end

    if @analysis.enable_subgame
      subgame_obj = SubgameSetter.new(@analysis.subgame_script)
    end

    if @analysis.enable_subgame || @analysis.analysis_script.enable_dominance
      dominance_obj = DominanceScriptSetter.new(@analysis)
    end
    
    @command_setter = CommandSetter.new(analysis_obj, reduction_obj, dominance_obj, subgame_obj, @path_finder)
  end

  def prepare_subgame
    last_game = @game.analyses.where("subgame IS NOT NULL").last    
    if last_game != nil
      @file_manager.prepare_subgame_input(last_game.subgame)
      @analysis.create_subgame_script(subgame: last_game.subgame)
    else
      @analysis.create_subgame_script()
    end
  end


                                                                                                                                                                                                                                                                                                                                                                                                                                    
  def set_commands
    @set_up_remote_command = @command_setter.set_up_remote_command
    @running_script_command = @command_setter.get_script_command
    @clean_up_command = @command_setter.clean_up_remote_command
  end

  def prepare_pbs
    AnalysisPbsFormatter.new(@analysis.pbs, @path_finder).write_pbs(@analysis.game_id.to_s, @set_up_remote_command, @running_script_command, @clean_up_command)
  end
  # def submit_job
  #   pbs_file = @pbs_formatter_obj.prepare_pbs(File.join(@path_finder.remote_pbs_path, @path_finder.pbs_error_file), File.join(@path_finder.remote_pbs_path,@path_finder.pbs_output_file), @set_up_remote_command, @running_script_command, @clean_up_command)
  #   @pbs_formatter_obj.write_pbs(pbs_file, File.join("#{@path_finder.local_pbs_path}","#{@path_finder.pbs_file_name}"))
    
    ####Comment with no access to flux
  #   @pbs_formatter_obj.submit(File.join("#{@path_finder.remote_pbs_path}","#{@path_finder.pbs_file_name}"))
  # end 
end
