class SubgameArgumentSetter < ScriptHandler
	attr_reader :subgame_exist
	def prepare_input(game, input_dir,input_file)
		subgame_json = game.subgames
		if subgame_json.blank?
			@subgame_exist = false
		else
			###################permission??
		    File.open(File.join(input_dir, input_file), 'w', 0770) do |f| 
         		f.write(subgame_json.to_json)
      	 	end
      	 	@subgame_exist = true
		end
	end

	def run_with_option(input_file_name,output_file_name,optional_argument = nil)
		# argument_list += @required_argument_hash.map{|k,v| "-#{k} #{v}"}.join(' ')
		#throw when optional argument input is blank
		# optional_argument.each{|option| argument_list += " -#{option} #{optional_argument_hash[option]} "}
		"python #{@script_name} detect optional_argument < #{input_file_name} > #{output_file_name}"
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
end