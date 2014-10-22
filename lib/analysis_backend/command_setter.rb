require_relative 'analysis_path_finder.rb'

class CommandSetter
	def initialize(analysis)
		
		@analysis_obj = analysis.analysis_script
		@reduction_obj = analysis.reduction_script
		@subgame_obj = analysis.subgame_script
		@dominance_obj = analysis.dominance_script
		@path_obj = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def set_up_remote_command				
		<<-DOCUMENT
module load python/2.7.5
mkdir #{@path_obj.working_dir} 
cp -r /nfs/wellman_ls/GameAnalysis/GameIO.py /tmp/${PBS_JOBID}
#{set_analysis}
#{set_reduction}
#{set_subgame}
#{set_dominance}
cd #{@path_obj.working_dir}
cp #{@path_obj.remote_input_path}/* .
mkdir out
export PYTHONPATH=$PYTHONPATH:#{@path_obj.scripts_path}
		DOCUMENT
	end

	def get_script_command
		analysis_command = @analysis_obj.get_command
		if @dominance_obj != nil
			dominance_command = @dominance_obj.get_command
		end	
		if @reduction_obj != nil
			reduction_command = @reduction_obj.get_command
		end
		if @subgame_obj != nil
			subgame_command = @subgame_obj.get_command
		end
		<<-DOCUMENT
#{reduction_command}
#{dominance_command}
#{subgame_command}
#{analysis_command}
		DOCUMENT
	end

	def clean_up_remote_command

		<<-DOCUMENT
cp #{@path_obj.working_dir}/out/* #{@path_obj.remote_output_path}
rm -rf #{@path_obj.working_dir}
		DOCUMENT

	end

	private

	def set_reduction
		if @reduction_obj != nil
			"#{@reduction_obj.set_up_remote}"
		end
	end
	
	def set_analysis
		"#{@analysis_obj.set_up_remote}"
	end

	def set_subgame
		if @subgame_obj != nil
			"#{@subgame_obj.set_up_remote}"
		end
	end

	def set_dominance
		if @dominance_obj != nil
			"#{@dominance_obj.set_up_remote}"
		end
	end
	
end
