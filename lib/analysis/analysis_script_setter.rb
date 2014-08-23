class AnalysisScriptSetter 
  def initialize(analysis, path_obj)
    @script_name = "AnalysisScript.py"
    @analysis = analysis
    @required_argument_list = "-r #{analysis.regret} -d #{analysis.dist} -s #{analysis.support} -c #{analysis.converge} -i #{analysis.iters} -p #{analysis.points}"
    @path_obj = path_obj
  end


  def set_input_file(input_file_name)
    @input_file_name = input_file_name
  end

  def set_output_file(output_file_name)
    @output_file_name = output_file_name
  end

  def check_optional_argument
    if @analysis.verbose
      add_argument(" --verbose ")
    end

    if @analysis.enable_dominance != nil
      add_argument(" -nd #{@path_obj.dominance_json_file_name} ")
    end
 
  end

  def add_argument(optional_argument)
    @required_argument_list = @required_argument_list + " #{optional_argument} "
  end

  def get_command
    check_optional_argument
    "python #{@script_name} #{@required_argument_list} #{@input_file_name} > #{@output_file_name}"
  end

  def set_up_remote_script(script_path, work_dir)
    "cp -r #{script_path}/#{@script_name} #{work_dir}"
  end

  def set_up_remote_input(input_file_path, work_dir)
    "cp -r #{input_file_path} #{work_dir}"
  end
  
end