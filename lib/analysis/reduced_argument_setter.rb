class ReducedArgumentSetter 
	def initialize(reduction_mode, reduced_num_array)
		@script_name = "Reductions.py"
		@reduction_mode = reduction_mode
		@reduced_num_array = reduced_num_array
	end

	def set_input_file(input_file_name)
	    @input_file_name = input_file_name
	end

	def set_output_file(output_file_name)
	    @output_file_name = output_file_name
	end

	def get_command
		"python #{@script_name} -input #{@input_file_name} -output #{@output_file_name} #{@reduction_mode} #{@reduced_num_array.join(' ')}"
	end

	def set_up_remote_script(script_path, work_dir)
    	"cp -r #{script_path}/#{@script_name} #{work_dir}"
  	end
	
end