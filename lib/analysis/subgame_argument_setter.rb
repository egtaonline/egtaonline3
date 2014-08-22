class SubgameArgumentSetter 
	def initialize
		@script_name = "Subgames.py"
	end
	


	def set_input_file(input_file_name)
	    @input_file_name = input_file_name
	end

	def set_output_file(output_file_name)
	    @output_file_name = output_file_name
	end

	def get_command
		if @subgame_exist
			<<-DOCUMENT
mv #{@output_file_name} old_#{@output_file_name}
python #{@script_name} detect -k old_#{@output_file_name} < #{@input_file_name} > #{@output_file_name}
			DOCUMENT
		else
			"python #{@script_name} detect < #{@input_file_name} > #{@output_file_name}"
		end
	end

	def set_up_remote(input_file_path,script_path, work_dir)
		if @subgame_exist
			<<-DOCUMENT
cp -r #{script_path}/#{@script_name} #{work_dir}
cp -r #{input_file_path} #{work_dir}
			DOCUMENT
		else
			"cp -r #{script_path}/#{@script_name} #{work_dir}"
		end
	end

	
  	def get_output(work_dir, filename, local_dir)
    	"cp -r #{work_dir}/#{filename} #{local_dir}"
  	end
end
