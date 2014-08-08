class ReducedArgumentSetter 
	def initialize(reduction_mode, reduced_num_array)
		@script_name = "Reductions.py"
		@reduction_mode = reduction_mode
		@reduced_num_array = reduced_num_array
	end
	def run_with_option(input_file_name,output_file_name)
		"python #{@script_name} -input #{input_file_name} -output #{output_file_name} #{@reduction_mode} #{@reduced_num_array.join(' ')}"
	end

	def set_up_remote_script(script_path, work_dir)
    	"cp -r #{script_path}/#{@script_name} #{work_dir}"
  	end
	
end