class ReducedArgumentSetter
	def initialize(reduced_mode, reduced_num_array,roles_count,input,output)
		# input_file, mode, roles, params,output_file)
		@input_file = input
		@mode = reduced_mode
		@output_file = output
		@roles_count = roles_count
		# @roles = params[:roles]
		# @roles.each do |role|
        @reduced_num_array = reduced_num_array
	end
	def acquire
		# "python Reductions.py -input #{@game.id}-analysis-#{@time}.json -output #{@game.id}-reduced-#{@time}.json #{@reduced_script_arg}"
		"python Reductions.py -input #{@input_file} -output #{@output_file} #{@mode} #{@reduced_num_array.join(' ')} "

	end
end