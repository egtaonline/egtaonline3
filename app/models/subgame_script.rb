class SubgameScript < ActiveRecord::Base
	belongs_to :analysis
	after_initialize :prepare

	def get_command
		if self.subgame
			"python #{@script_name} detect -k #{@path_obj.subgame_json_file_name} < ./out/#{@path_obj.dominance_json_file_name} > ./out/#{@path_obj.subgame_json_file_name}"
		else
			"python #{@script_name} detect < ./out/#{@path_obj.dominance_json_file_name} > ./out/#{@path_obj.subgame_json_file_name}"
		end
	end

	def set_up_remote
		"cp -r #{@path_obj.scripts_path}/#{@script_name} #{@path_obj.working_dir}"
	end

	private
	
	def prepare
		@script_name = "Subgames.py"
		@path_obj = AnalysisPathFinder.new(Analysis.find(analysis_id).game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	
end
