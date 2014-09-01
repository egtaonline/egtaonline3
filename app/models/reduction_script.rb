class ReductionScript < ActiveRecord::Base
	belongs_to :analysis
	after_initialize :prepare

	private

	def prepare
		@script_name = "Reductions.py"
		@path_obj = AnalysisPathFinder.new(Analysis.find(analysis_id).game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

	def set_output_file(output_file_name)
	    @output_file_name = output_file_name
	end

	def get_command
		"python #{@script_name} -input #{@path_obj.input_file_name} -output ./out/#{@path_obj.reduction_file_name}} #{self.mode} #{self.reduced_number}"
	end

	def set_up_remote_script(script_path, work_dir)
    	"cp -r #{script_path}/#{@script_name} #{work_dir}"
  	end
end
