# require 'analysis'

# describe ScriptsArgumentSetter do
# 	let(:analysis_obj){double("analysis_obj")}
# 	let(:reduction_obj){double ("reduction_obj")}
# 	let(:subgame_obj){double("subgame_obj")}
# 	let(:game){ double ("game")}
# 	let(:path_obj){double("path object")}
# 	context "when reduction and subgame options are checked" do
# 		before(:each) do
# 			@setter = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,subgame_obj)				
# 			@setter.set_path(path_obj)
# 		end

# 		describe "#set_path" do
# 			it "sets the right paht_finder object" do
# 				@setter = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,subgame_obj)				
# 				@setter.set_path(path_obj).should == path_obj
# 			end
# 		end

# 		describe "#prepare_input" do
# 			local_input_path = "local/analysis/game-id/in"
# 			input_file_name = "game-id-analysis-time.json"
# 			local_subgame_path = "local/analysis/game-id/subgame"
# 			subgame_json_file_name = "subgame.json"

# 			it "prepares the analysis script input" do
				
# 				path_obj.should_receive(:local_input_path).and_return(local_input_path)
# 				path_obj.should_receive(:input_file_name).and_return(input_file_name)
# 				analysis_obj.should_receive(:prepare_input).with(game,local_input_path,input_file_name)

# 				path_obj.stub(:local_subgame_path).and_return(local_subgame_path)
# 				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
# 				subgame_obj.stub(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
# 				@setter.prepare_input(game)
# 			end
			
# 			it "prepares the subgame script input" do
				
# 				path_obj.stub(:local_input_path).and_return(local_input_path)
# 				path_obj.stub(:input_file_name).and_return(input_file_name)
# 				analysis_obj.stub(:prepare_input).with(game,local_input_path,input_file_name)

# 				path_obj.should_receive(:local_subgame_path).and_return(local_subgame_path)
# 				path_obj.should_receive(:subgame_json_file_name).and_return(subgame_json_file_name)
# 				subgame_obj.should_receive(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				
# 				@setter.prepare_input(game)
# 			end

# 		end

# 		descrit "#set_up_remote_command" do
# 			it "sets up the remote for each of the script" do
# 				work_dir = "$JOB_ID"
# 				remote_input_path = "remote_input_path"
# 				input_file_name = "input_file_name"
# 				reduction_script_path = "reduction_script_path"
# 				remote_subgame_path = "remote_subgame_path"
# 				subgame_json_file_name = "subgame_json_file_name"
# 				subgame_script_path = "subgame_script_path"
# 				analysis_script_path = "analysis_script_path"

# 				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
# 				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
# 				reduction_set_up_command = "reduction_set_up_command"
# 				subgame_set_up_command = "subgame_set_up_command"

# 				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
# 				path_obj.stub(:remote_input_path).and_return(remote_input_path)
# 				path_obj.stub(:input_file_name).and_return(input_file_name)
# 				path_obj.stub(:reduction_script_path).and_return(reduction_script_path)
# 				path_obj.stub

# 			end
# 		end
# 	end			
	
	
	

# end

# class ScriptsArgumentSetter
# 	def initialize( analysis_obj,reduction_obj = nil,subgame_obj = nil)
# 		@analysis_obj = analysis_obj
# 		@reduction_obj = reduction_obj
# 		@subgame_obj = subgame_obj
# 	end

# 	def set_path(path_obj)
# 		@path_obj = path_obj
# 	end

# 	def prepare_input(game)
# 		@analysis_obj.prepare_input(game, @path_obj.local_input_path, @path_obj.input_file_name)
# 		if @subgame_obj != nil
# 			@subgame_obj.prepare_input(game, @path_obj.local_subgame_path, @path_obj.subgame_json_file_name)
# 		end
# 	end

# 	def set_up_remote_command
# 		work_dir = @path_obj.working_dir
# 		analysis_set_up_command = <<-DOCUMENT
# #{@analysis_obj.set_up_remote_script(@path_obj.analysis_script_path,work_dir)}
# #{@analysis_obj.set_up_remote_input(File.join(@path_obj.remote_input_path, @path_obj.input_file_name), work_dir)}
# 		DOCUMENT
# 		if @reduction_obj !=nil
# 			reduction_set_up_command = "#{@reduction_obj.set_up_remote_script(@path_obj.reduction_script_path,work_dir)}"
# 		end
# 		if @subgame_obj != nil
# 			subgame_set_up_command = "#{@subgame_obj.set_up_remote(File.join(@path_obj.remote_subgame_path, @path_obj.subgame_json_file_name),@path_obj.subgame_script_path, work_dir)}"			
# 		end

# 		<<-DOCUMENT
# module load python/2.7.5
# mkdir #{work_dir}
# #{analysis_set_up_command}
# #{reduction_set_up_command}
# #{subgame_set_up_command}
# cd #{work_dir}
# export PYTHONPATH=$PYTHONPATH:#{@path_obj.scripts_path}
# 		DOCUMENT
# 	end
	
# 	def get_script_command
# 		if @reduction_obj !=nil && @subgame_obj !=nil 
			
# 			<<-DOCUMENT
# #{@reduction_obj.run_with_option(@path_obj.input_file_name, @path_obj.reduction_file_name)}
# #{@subgame_obj.run_with_option(@path_obj.reduction_file_name, @path_obj.subgame_json_file_name, @path_obj.subgame_json_file_name)}
# #{@analysis_obj.run_with_option(@path_obj.reduction_file_name, @path_obj.output_file_name,"-sg #{@path_obj.subgame_json_file_name}")}
# 			DOCUMENT
		
# 		elsif @reduction_obj == nil && @subgame_obj != nil 

# 			<<-DOCUMENT
# #{@subgame_obj.run_with_option(@path_obj.input_file_name, @path_obj.subgame_json_file_name, @path_obj.subgame_json_file_name)}
# #{@analysis_obj.run_with_option(@path_obj.input_file_name, @path_obj.output_file_name,"-sg #{@path_obj.subgame_json_file_name}")}
# 			DOCUMENT

# 		elsif @reduction_obj !=nil && @subgame_obj == nil 
# 			<<-DOCUMENT
# #{@reduction_obj.run_with_option(@path_obj.input_file_name, @path_obj.reduction_file_name)}
# #{@analysis_obj.run_with_option(@path_obj.reduction_file_name, @path_obj.output_file_name)}		
# 			DOCUMENT
# 		else
# 			"#{@analysis_obj.run_with_option(@path_obj.input_file_name, @path_obj.output_file_name)}"		
# 		end
			
# 	end

# 	def clean_up_remote_command
# 		analysis_clean_up = @analysis_obj.get_output(@path_obj.working_dir, @path_obj.output_file_name, @path_obj.remote_output_path)
		
# 		if @subgame_obj != nil
# 			subgame_clean_up = @subgame_obj.get_output(@path_obj.working_dir, @path_obj.subgame_json_file_name, @path_obj.remote_subgame_path)
# 		end

# 		<<-DOCUMENT
# #{analysis_clean_up}
# #{subgame_clean_up}
# rm -rf #{@path_obj.working_dir}
# 		DOCUMENT

# 	end
# end