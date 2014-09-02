class AnalysisCleaner
	def initialize(game_id, analysis_id)
		@path_finder = AnalysisPathFinder.new(game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def clean
		FileUtils.rm_rf @path_finder.local_data_path
	end
end