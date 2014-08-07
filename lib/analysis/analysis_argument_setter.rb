class AnalysisArgumentSetter < ScriptHandler
  def initialize(script_name, required_argument_list)
    @script_name = script_name
    @required_argument_list = required_argument_list
    # @optional_argument_hash = optional_argument_hash
    # @argument_list = ""
  end
  def prepare_input(game, local_input_path, input_file_name)
    FileUtils.mv("#{GamePresenter.new(game).to_json()}",File.join("#{local_input_path}","#{input_file_name}"))
  end

  def run_with_option(input_file_name,output_file_name,optional_argument = nil)
    # argument_list += @required_argument_hash.map{|k,v| "-#{k} #{v}"}.join(' ')
    #throw when optional argument input is blank
    # optional_argument.each{|option| argument_list += " -#{option} #{optional_argument_hash[option]} "}
    "python #{@script_name} @required_argument_list optional_argument #{input_file_name} > #{output_file_name}"
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
  # include ActiveModel::Validations
  # validates_presence_of :regret
  # def initialize(input_file, output_file,regret, dist,support,converge,iters)
  #   @input_file = input_file
  #   @output_file = output_file
  #   @regret = regret
  #   @dist = dist
  #   @support = support
  #   @converge = converge
  #   @iters = iters
  # end 
  # def run_without_subgame
  #   "python AnalysisScript.py -r #{@regret} -d #{@dist} -s #{@support} -c #{@converge} -i #{@iters} #{@input_file} > #{@output_file}"
  # end
  # def run_with_subgame(subgame_file)
  #   "python AnalysisScript.py -sb #{subgame_file} -r #{@regret} -d #{@dist} -s #{@support} -c #{@converge} -i #{@iters} #{@input_file} > #{@output_file}"
  # end
end