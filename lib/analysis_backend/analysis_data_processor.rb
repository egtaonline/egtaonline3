class AnalysisDataProcessor
	def initialize(analysis)
		@analysis = analysis
		@path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
		# @path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "#{Rails.root}/app","/nfs/wellman_ls")
	end

	def process_files
		error_message = ""

#		error_message += "Incorrect reduction output," unless check_reduction_file
#		error_message += "Incorrect subgame output," unless check_subgame_file
#		error_message += "Incorrect dominance output," unless check_dominance_file
		error_message += "Incorrect analysis output," unless check_analysis_output

		if error_message.to_s.strip.length != 0 
			@analysis.fail(error_message)			
		else
			FileUtils.rm_rf(@path_finder.local_data_path)
			@analysis.finish
		end
			
	end

	private 

	def check_reduction_file
		reduction_script = @analysis.reduction_script
		if reduction_script
			reduction_script_output = File.join(@path_finder.local_output_path, @path_finder.reduction_file_name)
			if File.exist?(reduction_script_output)
				reduction_output = File.open(reduction_script_output).read
				reduction_script.output = reduction_output
				reduction_script.save	
				#throw
				# true			
			else
				false
			end
		else
			true	
		end
		
	end

	def check_subgame_file
		if  @analysis.subgame_script
			subgame_script_output = File.join(@path_finder.local_output_path, @path_finder.subgame_json_file_name)
			if File.exist?(subgame_script_output)
				subgame = File.open(subgame_script_output).read
				#throw
				@analysis.subgame = subgame
				@analysis.save
			else
				false
			end
		else
			true
		end
	end

	def check_dominance_file
		dominance_script = @analysis.dominance_script
		if dominance_script
			dominance_script_output = File.join(@path_finder.local_output_path, @path_finder.dominance_json_file_name)
			if File.exist?(dominance_script_output)
				dominance_output = File.open(dominance_script_output).read
				#throw
				dominance_script.output = dominance_output
				dominance_script.save	
				# true			
			else
				false
			end
		else
			true	
		end
	end

	def check_analysis_output
		analysis_out = File.join(@path_finder.local_output_path, @path_finder.output_file_name)
		if File.exist?(analysis_out)
			output = File.open(analysis_out).read
			@analysis.output = output
			@analysis.save	
			# true	
			#throw		
		else
			false
		end		

	end
end
