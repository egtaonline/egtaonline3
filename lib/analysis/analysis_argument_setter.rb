class AnalysisArgumentSetter 
  def initialize(required_argument_list)
    @script_name = "AnalysisScript.py"
    @required_argument_list = required_argument_list
  end


  def set_input_file(input_file_name)
    @input_file_name = input_file_name
  end

  def set_output_file(output_file_name)
    @output_file_name = output_file_name
  end

  def add_argument(optional_argument)
    @required_argument_list = @required_argument_list + " #{optional_argument} "
  end

  def get_command
    "python #{@script_name} #{@required_argument_list} #{@input_file_name} > #{@output_file_name}"
  end

  def set_up_remote_script(script_path, work_dir)
    "cp -r #{script_path}/#{@script_name} #{work_dir}"
  end

  def set_up_remote_input(input_file_path, work_dir)
    "cp -r #{input_file_path} #{work_dir}"
  end

  def get_output(work_dir, filename, local_dir)
    "cp -r #{work_dir}/#{filename} #{local_dir}"
  end
end