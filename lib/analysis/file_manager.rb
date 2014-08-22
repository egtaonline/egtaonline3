class FileManager
	def initialize(path_obj)
		@path_obj = path_obj
  	end

  	def created_folder
    	FileUtils::mkdir_p "#{@path_obj.local_output_path}", mode: 0770
    	FileUtils::mkdir_p "#{@path_obj.local_input_path}", mode: 0770
    	FileUtils::mkdir_p "#{@path_obj.local_pbs_path}", mode: 0770
    	FileUtils::mkdir_p "#{@path_obj.local_subgame_path}", mode: 0770
  	end

  	def prepare_analysis_input(game)
    	FileUtils.mv("#{GamePresenter.new(game).to_json()}",File.join("#{local_input_path}","#{input_file_name}"))   	  
  	end

  	def prepare_subgame_input(subgame)
		# subgame_json = game.subgames
		if subgame_json.blank?
			@subgame_exist = false
		else
		    File.open(File.join(input_dir, input_file), 'w', 0770) do |f| 
         		f.write(subgame_json.to_json)
         		f.chmod(0770)
      	 	end
      	 	@subgame_exist = true
		end
	end
end