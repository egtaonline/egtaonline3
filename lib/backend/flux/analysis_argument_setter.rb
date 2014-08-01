class AnalysisArgumentSetter
  # include ActiveModel::Validations
  # validates_presence_of :regret
  def initialize(options, input_file, output_file)
    @input_file = input_file
    @output_file = output_file
    @regret = options[:regret]
    @dist = options[:dist]
    @support = options[:support]
    @converge = options[:converge]
    @iters = options[:iters]
  end 
  def acquire
    "python AnalysisScript.py -r #{@regret} -d #{@dist} -s #{@support} -c #{@converge} -i #{@iters} #{@input_file} > #{@output_file}"
  end
end