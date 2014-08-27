class AnalysisPreparer
	def initialize(analysis)
		@analysis = analysis
		@path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def prepare_analysis
		file_manager = FileManager.new(@path_finder)
		file_manager.created_folder
		subgame_data = analysis.subgame
		if subgame_data 
			file_manager.prepare_subgame_input(subgame_data)
		end
	 	file_manager.prepare_analysis_input(Game.find(analysis.game_id))
	    file_manager.prepare_pbs(@analysis.pbs.scripts)
	end
end