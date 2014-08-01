
class AnalysisPathFinder
  attr_reader :scripts_path
  def initialize(game_id,time,local_path,remote_path)
    @game_id = game_id
    @remote_data_path = File.join(remote_path,'egtaonline','analysis',@game_id)
    @local_data_path = File.join(local_path,'analysis',@game_id)
    @scripts_path = File.join(remote_path,'GameAnalysis')
    @time = time
  end


  def local_input_path
    File.join(@local_data_path, 'in')
  end

  def local_output_path
    File.join(@local_data_path, 'out')
  end

  def local_pbs_path
  	File.join(@local_data_path, 'pbs')
  end

  def remote_pbs_path
  	File.join(@remote_data_path, 'pbs')
  end

  def remote_input_path
    File.join(@remote_data_path, 'in')
  end

  def remote_output_path
    File.join(@remote_data_path, 'out')
  end

  def remote_reduction_path
    File.join(@remote_data_path, 'reduced_game')
  end

  def analysis_script_path
    File.join(@scripts_path,"scripts","AnalysisScript.py" )
  end

  def reduction_script_path
    File.join(@scripts_path,"scripts","Reductions.py" )
  end

  def input_file_name
    "#{@game_id}-analysis-#{@time}.json"
  end

  def ouput_file_name
    "#{@game_id}-analysis-#{@time}.out"
  end

  def reduction_file_name
    "#{@game_id}-reduced-#{@time}.json"
  end

  def pbs_file_name
    "#{@game_id}-wrapper-#{@time}"
  end

end