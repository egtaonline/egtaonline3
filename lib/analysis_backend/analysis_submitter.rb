class AnalysisSubmitter
	def initialize(analysis)
		@analysis = analysis
		@path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end
  def submit
    proxy = Backend.connection.acquire
    # proxy = nil
    if proxy
      begin
        response = proxy.exec!("SBATCH --export=All --no-requeue #{File.join(@path_finder.remote_pbs_path, @path_finder.pbs_file_name)}") 
        if response =~ /\A(\d+)/
          @analysis.queue_as Regexp.last_match[0].to_i
        else
          @analysis.fail "Submission failed: #{response}"
        end
      rescue => e
        @analysis.fail "Submission failed: #{e}"
      end
    else
      @analysis.fail "Lost connection to flux"
    end
  end
end
