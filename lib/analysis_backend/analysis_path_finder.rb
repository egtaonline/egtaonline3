class AnalysisPathFinder
  attr_reader :local_data_path, :scripts_path, :remote_data_path
  def initialize(game_id,analysis_id,local_path,remote_path)
    @game_id = game_id.to_s 
    @analysis_id = analysis_id.to_s 
    @remote_data_path = File.join(remote_path,'egtaonline','analysis',@game_id, @analysis_id )
    @local_data_path = File.join(local_path,'analysis',@game_id, @analysis_id)
    @scripts_path = File.join(remote_path,'game_analysis')   
  end

  def local_input_path
    File.join(@local_data_path,"in")
  end

  def local_output_path
    File.join(@local_data_path,"out")
  end
  
  def local_pbs_path
    File.join(@local_data_path,"sh")
  end
  
  def remote_input_path
    File.join(@remote_data_path,"in")
  end

  def remote_output_path
    File.join(@remote_data_path,"out")
  end
  
  def remote_pbs_path
    File.join(@remote_data_path,"sh")
  end

  def pbs_error_file
    "#{@game_id}-analysis-#{@analysis_id}-sh.e"
  end

  def pbs_output_file
    "#{@game_id}-analysis-#{@analysis_id}-sh.o"
  end

  def working_dir 
    "/tmp/${SLURM_JOB_ID}"
  end

  def input_file_name
    "#{@game_id}-analysis-#{@analysis_id}.json"
  end

  def output_file_name
    "#{@game_id}-analysis-#{@analysis_id}.txt"
  end

  def reduction_file_name
    "#{@game_id}-reduced-#{@analysis_id}.json"
  end

  def subgame_json_file_name
    "#{@game_id}-subgame-#{@analysis_id}.json"
  end

  def dominance_json_file_name
    "#{@game_id}-dominance-#{@analysis_id}.json"
  end

  def pbs_file_name
    "#{@game_id}-wrapper-#{@analysis_id}"
  end

end
