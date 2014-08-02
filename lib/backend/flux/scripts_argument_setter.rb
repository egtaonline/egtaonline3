require_relative 'reduced_argument_setter.rb'
require_relative 'analysis_argument_setter.rb'

class ScriptsArgumentSetter
	# def self.scriptCommand(enable_reduced,reduced_num_array,roles_count, reduced_mode, path_finder, analysis_hash)
	def self.scriptCommand(enable_reduced,reduced_num_array,roles_count, reduced_mode, path_finder, regret, dist, support, converge, iters)
		if( enable_reduced != nil)
		ReducedArgumentSetter.new(reduced_mode, reduced_num_array, roles_count, path_finder.input_file_name, path_finder.reduction_file_name).acquire + "\n" + AnalysisArgumentSetter.new(path_finder.reduction_file_name, path_finder.output_file_name, regret, dist, support, converge, iters).acquire
		else
		   AnalysisArgumentSetter.new(path_finder.input_file_name, path_finder.output_file_name, regret, dist, support, converge, iters).acquire
		end
	end
end