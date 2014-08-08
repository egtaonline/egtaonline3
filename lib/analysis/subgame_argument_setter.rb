class SubgameArgumentSetter 
	def initialize
		@script_name = "Subgames.py"
	end
	def prepare_input(game, input_dir, input_file)
		
		subgame_json = game.subgames
		if subgame_json.blank?
			@subgame_exist = false
		else
		    File.open(File.join(input_dir, input_file), 'w', 0770) do |f| 
         		f.write(subgame_json.to_json)
      	 	end
      	 	@subgame_exist = true
		end
	end

	def run_with_option(input_file_name, output_file_name, subgame_file_name = nil)
		# argument_list += @required_argument_hash.map{|k,v| "-#{k} #{v}"}.join(' ')
		#throw when optional argument input is blank
		# optional_argument.each{|option| argument_list += " -#{option} #{optional_argument_hash[option]} "}
		if @subgame_exist
			"python #{@script_name} detect  -k #{subgame_file_name} < #{input_file_name} > #{output_file_name}"
		else
			"python #{@script_name} detect  < #{input_file_name} > #{output_file_name}"

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