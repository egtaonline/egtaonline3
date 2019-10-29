require_relative 'analysis_path_finder.rb'

class FileManager
	
  def initialize(path_obj)
    @path_obj = path_obj
  end
  def created_folder
    FileUtils.rm_rf("#{@path_obj.local_data_path}")
    FileUtils::mkdir_p "#{@path_obj.local_data_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_obj.local_input_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_obj.local_output_path}", mode: 0770
    FileUtils::mkdir_p "#{@path_obj.local_pbs_path}", mode: 0770
  end

  def prepare_analysis_input(game)
    FileUtils.mv("#{GamePresenter.new(game).to_json()}",File.join("#{@path_obj.local_input_path}","#{@path_obj.input_file_name}"))   	  
  end

  def prepare_subgame_input(subgame_json)
    File.open(File.join(@path_obj.local_input_path, @path_obj.subgame_json_file_name), 'w', 0770) do |f| 
      f.write(subgame_json.to_json)
      f.chmod(0770)
    end
  end

  def prepare_pbs(pbs_file)
	   File.open("#{File.join(@path_obj.local_pbs_path, @path_obj.pbs_file_name)}", 'w', 0770) do |f|
         f.write(pbs_file)
      end
  end

end
