require_relative 'analysis_path_finder.rb'

class CommandSetter
	def initialize(analysis)		
		@analysis_obj = analysis.analysis_script
		@reduction_obj = analysis.reduction_script
		@subgame_obj = analysis.subgame_script
		@dominance_obj = analysis.dominance_script

		#Add learning_obj
		@learning_obj = analysis.learning_script

		@path_obj = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def set_up_remote_command				
		<<-DOCUMENT
module load python/3.7.4
mkdir #{@path_obj.working_dir} 
cd #{@path_obj.working_dir}
cp #{@path_obj.remote_input_path}/* .
mkdir out
export PYTHONPATH=$PYTHONPATH:#{@path_obj.scripts_path}
		DOCUMENT
	end

	def get_script_command
		if @learning_obj != nil
			analysis_command = @learning_obj.get_command
		else
			analysis_command = @analysis_obj.get_command
		end
		<<-DOCUMENT
#{analysis_command}
		DOCUMENT
	end

	def clean_up_remote_command

		<<-DOCUMENT
cp #{@path_obj.working_dir}/out/* #{@path_obj.remote_output_path}
rm -rf #{@path_obj.working_dir}
		DOCUMENT

	end
	
end
