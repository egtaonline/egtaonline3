require_relative 'reduced_argument_setter.rb'
require_relative 'analysis_argument_setter.rb'
require_relative 'subgame_argument_setter.rb'
require_relative 'analysis_path_finder.rb'
require_relative 'dominance_argument_setter.rb'

class CommandSetter
	def initialize(analysis_obj, reduction_obj, dominance_obj, subgame_obj, path_finder)
		@path_obj = path_finder
		@analysis_obj = analysis_obj
		@reduction_obj = reduction_obj
		@subgame_obj = subgame_obj
		@dominance_obj = dominance_obj
	end

	def set_up_remote_command				
		<<-DOCUMENT
module load python/2.7.5
mkdir #{@path_obj.working_dir} 
#{set_analysis}
#{set_reduction}
#{set_subgame}
#{set_dominance}
cd #{@path_obj.working_dir}
cp #{@path_obj.remote_data_path}/* .
mkdir out
export PYTHONPATH=$PYTHONPATH:#{@path_obj.scripts_path}
		DOCUMENT
	end

	def get_script_command
		set_up_input_output
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
cp #{@path_obj.working_dir}/out/* #{@path_obj.remote_data_path}
rm -rf #{@path_obj.working_dir}
		DOCUMENT

	end

	private

	def set_reduction
		if @reduction_obj != nil
			"#{@reduction_obj.set_up_remote_script(@path_obj.scripts_path,@path_obj.working_dir)}"
		end
	end
	
	def set_analysis
		"#{@analysis_obj.set_up_remote_script(@path_obj.scripts_path,@path_obj.working_dir)}"
	end

	def set_subgame
		if @subgame_obj != nil
			"#{@subgame_obj.set_up_remote_script(@path_obj.scripts_path,@path_obj.working_dir)}"
		end
	end

	def set_dominance
		if @dominance_obj != nil
			"#{@dominance_obj.set_up_remote_script(@path_obj.dominance_script_path, @path_obj.working_dir)}"
		end
	end
	

	def set_up_input_output
		if @reduction_obj != nil
			@reduction_obj.set_input_file(@path_obj.input_file_name)
			@reduction_obj.set_output_file(@path_obj.reduction_file_name)
			if @dominance_obj != nil
				@dominance_obj.set_input_file(@path_obj.reduction_file_name)
			end
			@analysis_obj.set_input_file(@path_obj.reduction_file_name)
			if @subgame_obj != nil
				@subgame_obj.set_input_file(@path_obj.reduction_file_name)
			end
		else
			if @dominance_obj != nil
				@dominance_obj.set_input_file(@path_obj.input_file_name)
			end
			@analysis_obj.set_input_file(@path_obj.input_file_name)
		end

		if @subgame_obj != nil 
			@subgame_obj.set_input_file(@path_obj.dominance_json_file_name)
			@subgame_obj.set_output_file(@path_obj.subgame_json_file_name)
			@analysis_obj.add_argument(" -sg #{@path_obj.subgame_json_file_name} ")
		end

		if @dominance_obj != nil
			@dominance_obj.set_output_file(@path_obj.dominance_json_file_name)
		end
		@analysis_obj.set_output_file(@path_obj.output_file_name)
	end
end