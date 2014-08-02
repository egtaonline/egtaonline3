class AnalysisArgumentSetter
  # include ActiveModel::Validations
  # validates_presence_of :regret
  def initialize(input_file, output_file,regret, dist,support,converge,iters)
    @input_file = input_file
    @output_file = output_file
    @regret = regret
    @dist = dist
    @support = support
    @converge = converge
    @iters = iters
  end 
  def acquire
    "python AnalysisScript.py -r #{@regret} -d #{@dist} -s #{@support} -c #{@converge} -i #{@iters} #{@input_file} > #{@output_file}"
  end
end