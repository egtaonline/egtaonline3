class AnalysisStatusResolver
	ERROR_LIMIT = 255
	def initialize(analysis)
		@analysis = analysis
		@path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def act_on_status(status)
	    case status
	    when 'R'
	      analysis.start
	    when 'C', '', nil
	      if File.exist?(File.join(@path_finder.remote_data_path, @path_finder.pbs_error_file))
	        error_message = File.open(File.join(@path_finder.remote_data_path, @path_finder.pbs_error_file))
	          .read(ERROR_LIMIT)
	        if error_message
	          analysis.fail(error_message)
	        else
	          analysis.process
	        end
	      elsif analysis.state == 'queued'
	        analysis.start
	      else
	        analysis.fail('Failed to queue')
	      end
	    end
  	end
end