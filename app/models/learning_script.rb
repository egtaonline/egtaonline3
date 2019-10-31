class LearningScript < ActiveRecord::Base
	belongs_to :analysis
	after_initialize :prepare

	def get_command
	    "/nfs/wellman_ls/game_analysis_gl/ga learning -i #{@input_file_name} -o ./out/#{@path_obj.output_file_name} #{@required_argument_list}"
	end

	def set_up_remote
	    "cp -r #{@path_obj.scripts_path}/#{@script_name} #{@path_obj.working_dir}"
	end

	def set_input_file
		@input_file_name = @path_obj.input_file_name
	end

	def check_optional_argument
	   if self.verbose != false
	      add_argument("--verbose")
	   end

	   #if self.enable_dominance != false
	   #   add_argument(" -nd out/#{@path_obj.dominance_json_file_name} ")
	   #end

	   #if @analysis.subgame_script != nil
	   #	  add_argument(" -sg out/#{@path_obj.subgame_json_file_name} ")
	   #end
	end


	def add_argument(optional_argument)
	   @required_argument_list = @required_argument_list + " #{optional_argument} "
	end

	private

	def prepare
		set_up_variables
		#set_input_file
		#check_optional_argument
	end

	def set_up_variables
		@script_name = "GameLearning.py"
	    @analysis = Analysis.find(analysis_id)
	    @required_argument_list = "--dist-thresh #{self.dist} -r #{self.regret} -t #{self.support} --rand-restarts #{self.points} -c #{self.converge} -m #{self.iters}"
	    @path_obj = AnalysisPathFinder.new(@analysis.game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end

end
