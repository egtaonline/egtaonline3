require_relative 'command_setter.rb'
require_relative  'analysis_pbs_formatter.rb'
require_relative 'file_manager.rb'
require_relative 'reduced_script_setter.rb'
require_relative 'analysis_script_setter.rb'
require_relative 'subgame_setter.rb'
require_relative 'analysis_path_finder.rb'
require_relative 'dominance_script_setter.rb'


class AnalysisManager 
  def initialize(analysis)
    # @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "#{Rails.root}/app","/nfs/wellman_ls")
    @analysis = analysis
    @file_manager = FileManager.new(@path_finder)

  end

  def prepare_analysis
    create_script_setters
    set_commands
    prepare_pbs
  end

  private

  def create_script_setters
    analysis_obj = AnalysisScriptSetter.new(@analysis.analysis_script, @path_finder)
    if @analysis.enable_reduction
      reduction_obj = ReducedScriptSetter.new(@analysis.reduction_script)
    end

    if @analysis.enable_subgame != nil
      prepare_subgame
      subgame_obj = SubgameSetter.new(@analysis.subgame_script)
    end

    if @analysis.enable_subgame != nil || @analysis.analysis_script.enable_dominance != nil
      dominance_obj = DominanceScriptSetter.new(@analysis)
    end
    
    @command_setter = CommandSetter.new(analysis_obj, reduction_obj, dominance_obj, subgame_obj, @path_finder)
  end

  def prepare_subgame
    last_game = Game.find(@analysis.game_id).analyses.where("subgame IS NOT NULL").last    
    if last_game != nil
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
    AnalysisPbsFormatter.new(@analysis.pbs, @path_finder).format(@analysis.game_id.to_s, @set_up_remote_command, @running_script_command, @clean_up_command)
  end

end
