require_relative 'command_setter.rb'
require_relative 'file_manager.rb'
require_relative 'analysis_path_finder.rb'


class AnalysisManager 
  def initialize(analysis)
    # @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "#{Rails.root}/app","/nfs/wellman_ls")
    @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    @analysis = analysis
    @file_manager = FileManager.new(@path_finder)
  end

  def prepare_analysis
    create_script_setter
    set_commands
    prepare_pbs
  end

  private

  def create_script_setter
    # Loads all the scripts, need to add learning_script here (if enable_learning is true)
    if @analysis.enable_learning == true
      if @analysis.learning_script.enable_dominance != false
        @analysis.create_dominance_script()
      end

      @analysis.learning_script.set_input_file
      @analysis.learning_script.check_optional_argument

      @command_setter = CommandSetter.new(@analysis)
    else
      if @analysis.enable_subgame != false
        prepare_subgame
      end

      if @analysis.enable_subgame != false || @analysis.analysis_script.enable_dominance != false
        @analysis.create_dominance_script()
      end

      @analysis.analysis_script.set_input_file
      @analysis.analysis_script.check_optional_argument

      @command_setter = CommandSetter.new(@analysis)
    end

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
    @analysis.pbs.format(@set_up_remote_command, @running_script_command, @clean_up_command)
  end

end
