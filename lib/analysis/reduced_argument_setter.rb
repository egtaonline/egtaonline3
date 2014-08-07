class ReducedArgumentSetter < ScriptHandler
	def initialize(script_name, reduction_mode, reduced_num_array)
		@script_name = script_name
		@reduction_mode = reduction_mode
		@reduced_num_array = reduced_num_array
	end
	def run_with_option(input_file_name,output_file_name)
		"python #{@script_name} -input #{input_file_name} -output #{output_file_name} #{@reduction_mode} #{@reduced_num_array.join(' ')}"
	end

	def set_up_remote_script(script_path, work_dir)
    	"cp -r #{script_path}/#{@script_name} #{work_dir}"
  	end
	# def initialize(reduced_mode, reduced_num_array,roles_count,input,output)
	# 	# input_file, mode, roles, params,output_file)
	# 	@input_file = input
	# 	@mode = reduced_mode
	# 	@output_file = output
	# 	@roles_count = roles_count
	# 	# @roles = params[:roles]
	# 	# @roles.each do |role|
 	#  
	# end
	# def acquire
	# 	# "python Reductions.py -input #{@game.id}-analysis-#{@time}.json -output #{@game.id}-reduced-#{@time}.json #{@reduced_script_arg}"
	# 	"python Reductions.py -input #{@input_file} -output #{@output_file} #{@mode} #{@reduced_num_array.join(' ')} "

	# end
	# def prepare_input(game)
	
	# end
end