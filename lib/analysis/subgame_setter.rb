class SubgameSetter 
	def initialize(subgame)
		@subgame = subgame
		@script_name = "Subgames.py"
	end


	def set_input_file(input_file_name)
	    @input_file_name = input_file_name
	end

	def set_output_file(output_file_name)
	    @output_file_name = output_file_name
	end

	def get_command
		if @subgame.subgame
			<<-DOCUMENT
mv #{@output_file_name} old_#{@output_file_name}
python #{@script_name} detect -k old_#{@output_file_name} < #{@input_file_name} > #{@output_file_name}
			DOCUMENT
		else
			"python #{@script_name} detect < #{@input_file_name} > #{@output_file_name}"
		end
	end

	def set_up_remote_script(script_path, work_dir)
		"cp -r #{script_path}/#{@script_name} #{work_dir}"
	end

end