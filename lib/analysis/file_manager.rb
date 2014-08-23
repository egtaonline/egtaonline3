class FileManager
	
  def initialize(path_obj)
    @path_obj = path_obj
  end
  def created_folder
    FileUtils::mkdir_p "#{@path_obj.local_data_path}", mode: 0770
  end

  def prepare_analysis_input(game)
    FileUtils.mv("#{GamePresenter.new(game).to_json()}",File.join("#{@path_obj.local_data_path}","#{@path_obj.input_file_name}"))   	  
  end

  def prepare_subgame_input(subgame_json)
    File.open(File.join(@path_obj.local_data_path, @path_obj.subgame_json_file_name), 'w', 0770) do |f| 
      f.write(subgame_json.to_json)
      f.chmod(0770)
    end
  end

	
end