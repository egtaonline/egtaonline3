class AnalysisArgumentSetter 
  def initialize(required_argument_list)
    @script_name = "AnalysisScript.py"
    @required_argument_list = required_argument_list
  end

  def prepare_input(game, local_input_path, input_file_name)
    FileUtils.mv("#{GamePresenter.new(game).to_json()}",File.join("#{local_input_path}","#{input_file_name}"))
  end

  def run_with_option(input_file_name,output_file_name,optional_argument = nil)
    "python #{@script_name} #{@required_argument_list} #{optional_argument} #{input_file_name} > #{output_file_name}"
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