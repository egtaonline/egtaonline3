require_relative 'reduced_argument_setter.rb'
require_relative 'analysis_argument_setter.rb'

class ScriptsArgumentSetter
	def self.scriptCommand(enable_reduced, analysis_hash, reduced_num_array,roles_count, reduced_mode, path_finder)
		if( enable_reduced != nil)
		   <<-DOCUMENT
#{ReducedArgumentSetter.new(reduced_mode, reduced_num_array, roles_count, path_finder.input_file_name, path_finder.reduction_file_name).acquire}
#{AnalysisArgumentSetter.new(analysis_hash, path_finder.reduction_file_name, path_finder.output_file_name).acquire}
		   DOCUMENT
		else
		   AnalysisArgumentSetter.new(analysis_hash, path_finder.input_file_name, path_finder.output_file_name).acquire
		end
	end
end