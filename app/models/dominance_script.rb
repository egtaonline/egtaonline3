class DominanceScript < ActiveRecord::Base
	belongs_to :analysis
	after_initialize :prepare
	
	
	def get_command
		"python #{@script_name} < #{@input_file_name} > #{@output_file_name}"
	end

	def set_up_remote
    	"cp -r #{@path_obj.scripts_path}/#{@script_name} #{@path_obj.working_dir}"
  	end

	private

	def prepare
		set_up_variables
		set_input_file
	end

	def set_up_variables
		@script_name = "Dominance.py"
		@analysis = Analysis.find(analysis_id)
		@path_obj = AnalysisPathFinder.new(@analysis.game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def set_input_file
		if @analysis.reduction_script != nil
			@input_file_name = "./out/#{@path_obj.reduction_file_name}"
		else
			@input_file_name = @path_obj.input_file_name
		end
	end

	
end
