require 'analysis'

describe ScriptsArgumentSetter do

	describe "#initialize" do
		context "when subgame obj and enable_dominance are not nil" do							
			it "sets dominance object" do 
				analysis_obj = double("analysis_obj")
				reduction_obj = double ("reduction_obj")
				subgame_obj = double("subgame_obj")
				enable_dominance  = true
				@setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
				@setter.instance_variable_get(:@dominance_obj).should_not be_nil
			end
		end
		context "when subgame obj is nil and enable_dominance is not" do
			
			it "sets dominance object" do 
				analysis_obj = double("analysis_obj")
				reduction_obj = double ("reduction_obj")
				enable_dominance  = true
				@setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,nil)
				@setter.instance_variable_get(:@dominance_obj).should_not be_nil
			end
		end
		context "when enable_dominance obj is nil and subgame obj is not" do
			
			it "sets dominance object" do 
				analysis_obj = double("analysis_obj")
				reduction_obj = double ("reduction_obj")
				subgame_obj = double("subgame_obj")
				@setter = ScriptsArgumentSetter.new(analysis_obj,nil,reduction_obj,subgame_obj)
				@setter.instance_variable_get(:@dominance_obj).should_not be_nil
			end
		end

		context "when enable_dominance obj  and subgame obj are both nil" do
			
			it "should not set dominance object" do 
				analysis_obj = double("analysis_obj")
				reduction_obj = double ("reduction_obj")
				@setter = ScriptsArgumentSetter.new(analysis_obj,nil,reduction_obj,nil)
				@setter.instance_variable_get(:@dominance_obj).should be_nil
			end
		end
	end

	describe "#set_path" do
		it "sets the right paht_finder object" do
			analysis_obj = double("analysis_obj")
			reduction_obj = double ("reduction_obj")
			subgame_obj = double("subgame_obj")
			path_obj = AnalysisPathFinder.new("1","200001011030","local_path","remote_path")
			enable_dominance  = true
			@setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)			
			@setter.set_path(path_obj).should == path_obj
		end
	end

	describe "#prepare_input" do
		it "prepares the analysis script input" do
			analysis_obj = double("analysis_obj")
			game = double(id:1)
			subgame_obj = double("subgame_obj")
			reduction_obj = double ("reduction_obj")
			path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
			enable_dominance  = true
			analysis_obj.should_receive(:prepare_input).with(game,path_obj.local_input_path,path_obj.input_file_name)
			subgame_obj.stub(:prepare_input).with(game,path_obj.local_subgame_path, path_obj.subgame_json_file_name)
			setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
			setter.set_path(path_obj)
			setter.prepare_input(game)
		end
		
		context "when subgame object is not nil"	
			it "prepares the subgame script input" do				
				analysis_obj = double("analysis_obj")
				game = double(id:1)
				subgame_obj = double("subgame_obj")
				reduction_obj = double ("reduction_obj")
				path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
				enable_dominance  = true
				analysis_obj.stub(:prepare_input).with(game,path_obj.local_input_path,path_obj.input_file_name)
				subgame_obj.should_receive(:prepare_input).with(game,path_obj.local_subgame_path, path_obj.subgame_json_file_name)
				setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
				setter.set_path(path_obj)
				setter.prepare_input(game)
			
			end
		end

		context "when subgame object is nil" do
			it "should_not prepare the subgame script input" do				
				analysis_obj = double("analysis_obj")
				game = double(id:1)
				subgame_obj = double("subgame_obj")
				reduction_obj = double ("reduction_obj")
				path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
				enable_dominance  = true
			
				analysis_obj.stub(:prepare_input).with(game,path_obj.local_input_path,path_obj.input_file_name)
				subgame_obj.should_not_receive(:prepare_input).with(game, path_obj.local_subgame_path, path_obj.subgame_json_file_name)
				
				setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,nil)
				setter.set_path(path_obj)
				setter.prepare_input(game)
			end
		end
	

		describe "#set_up_remote_command" do
			it "sets up the remote for each of the script" do
				analysis_obj = double("analysis_obj")
				game = double(id:1)
				subgame_obj = double("subgame_obj")
				reduction_obj = double ("reduction_obj")
				path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
				enable_dominance  = true
			
				analysis_obj.stub(:prepare_input).with(game,path_obj.local_input_path,path_obj.input_file_name)
				subgame_obj.should_not_receive(:prepare_input).with(game, path_obj.local_subgame_path, path_obj.subgame_json_file_name)


				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				reduction_set_up_command = "reduction_set_up_command"
				subgame_set_up_command = "subgame_set_up_command"
				dominance_set_up_command = "dominance_set_up_command"

				remote_input = File.join(path_obj.remote_input_path, path_obj.input_file_name)
				subgame_input = File.join(path_obj.remote_subgame_path, path_obj.subgame_json_file_name)
				analysis_obj.should_receive(:set_up_remote_script).with(path_obj.analysis_script_path,path_obj.working_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.should_receive(:set_up_remote_input).with(remote_input,path_obj.working_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.should_receive(:set_up_remote_script).with(path_obj.reduction_script_path, path_obj.working_dir).and_return(reduction_set_up_command)
				subgame_obj.should_receive(:set_up_remote).with(subgame_input,path_obj.scripts_path, path_obj.working_dir ).and_return(subgame_set_up_command)
				
				setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
				setter.set_path(path_obj)
				setter.instance_variable_get(:@dominance_obj).should_receive(:set_up_remote_script).with(path_obj.dominance_script_path, path_obj.working_dir).and_return(dominance_set_up_command)
				expect(setter.set_up_remote_command).to eq("module load python/2.7.5\n" \
				   "mkdir /tmp/${PBS_JOBID}\n" \
	               "analysis_set_up_remote_script_command\n" \
	               "analysis_set_up_remote_input_command\n\n" \
	               "reduction_set_up_command\n" \
	               "subgame_set_up_command\n" \
	               "dominance_set_up_command\n" \
	               "cd /tmp/${PBS_JOBID}\n" \
	               "export PYTHONPATH=$PYTHONPATH:#{path_obj.scripts_path}\n")				
			end
			
		end

		describe "#get_script_command" do

			it "runs four scripts" do
				analysis_obj = double("analysis_obj")
				game = double(id:1)
				subgame_obj = double("subgame_obj")
				reduction_obj = double ("reduction_obj")
				path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
				enable_dominance  = true
			
				setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
				setter.set_path(path_obj)

				setter.should_receive(:set_up_input_output)
				running_reduction_command = "running_reduction_command"
				running_subgame_command = "running_subgame_command"
				running_analysis_command = "running_analysis_command"
				running_dominance_command = "running_dominance_command"

				reduction_obj.should_receive(:get_command).and_return(running_reduction_command)
				subgame_obj.should_receive(:get_command).and_return(running_subgame_command)
				analysis_obj.should_receive(:get_command).and_return(running_analysis_command)
				setter.instance_variable_get(:@dominance_obj).should_receive(:get_command).and_return(running_dominance_command)

				expect(setter.get_script_command).to eq("running_reduction_command\n" \
					"running_dominance_command\n" \
				   "running_subgame_command\n" \
	               "running_analysis_command\n")
			end
		end

		describe "#clean_up_remote_command" do
			context "when subgame obj is not nil" do
				it "gets the analysis and subgame script outputs back" do
					analysis_obj = double("analysis_obj")
					game = double(id:1)
					subgame_obj = double("subgame_obj")
					reduction_obj = double ("reduction_obj")
					path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
					enable_dominance  = true
				
					setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
					setter.set_path(path_obj)



					analysis_clean_up = "analysis_clean_up"
					subgame_clean_up = "subgame_clean_up"

					analysis_obj.should_receive(:get_output).with(path_obj.working_dir, path_obj.output_file_name, path_obj.remote_output_path).and_return(analysis_clean_up)
					subgame_obj.should_receive(:get_output).with(path_obj.working_dir,path_obj.subgame_json_file_name, path_obj.remote_subgame_path).and_return(subgame_clean_up)

					expect(setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
					   "subgame_clean_up\n" \
		               "rm -rf /tmp/${PBS_JOBID}\n")
				end
			end

			context "when subgame obj is  nil" do
				it "should not get subgame script output back" do
					analysis_obj = double("analysis_obj")
					game = double(id:1)
					subgame_obj = double("subgame_obj")
					reduction_obj = double ("reduction_obj")
					path_obj = AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")				
					enable_dominance  = true
				
					setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,nil)
					setter.set_path(path_obj)



					analysis_clean_up = "analysis_clean_up"

					analysis_obj.stub(:get_output).with(path_obj.working_dir, path_obj.output_file_name, path_obj.remote_output_path).and_return(analysis_clean_up)
					subgame_obj.should_not_receive(:get_output).with(path_obj.working_dir,path_obj.subgame_json_file_name, path_obj.remote_subgame_path)

					expect(setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
					   "\n" \
		               "rm -rf /tmp/${PBS_JOBID}\n")
				end

			end
		end

	describe "#set_up_input_output" do
		context "when nothing is  nil" do
			let(:analysis_obj) {double("analysis_obj")}
			let(:game) { double(id:1)}
			let(:subgame_obj) {double("subgame_obj")}
			let(:reduction_obj){ double ("reduction_obj")}
			let(:path_obj){AnalysisPathFinder.new(game.id.to_s,"200001011030","local_path","remote_path")}			
			let(:enable_dominance){true} 
			before(:each) do
		    	
				@setter = ScriptsArgumentSetter.new(analysis_obj,enable_dominance,reduction_obj,subgame_obj)
				@setter.set_path(path_obj)
      		end
			it "sets original input file for reduction script input" do
				reduction_obj.should_receive(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.should_receive(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.stub(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.stub(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.stub(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.stub(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).stub(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
			end

			it "sets reduction output file for dominance script input" do
				reduction_obj.stub(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.stub(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.stub(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.stub(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.stub(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.stub(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).should_receive(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
			end

			it "sets dominance output file for subgame script input" do
				reduction_obj.stub(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.stub(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.stub(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.should_receive(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.stub(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.stub(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).stub(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
			end

			it "sets original input file for analysis script input" do
				reduction_obj.stub(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.stub(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.should_receive(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.stub(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.stub(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.stub(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).stub(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
			end

			it "sets subgame json file for analysis script" do
				reduction_obj.stub(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.stub(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.stub(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.stub(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.should_receive(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.stub(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).stub(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
			end

			it "sets dominance json file for analysis script" do
				reduction_obj.stub(:set_input_file).with(path_obj.input_file_name)
				reduction_obj.stub(:set_output_file).with(path_obj.reduction_file_name)
				@setter.instance_variable_get(:@dominance_obj).stub(:set_input_file).with(path_obj.reduction_file_name)
				analysis_obj.stub(:set_input_file).with(path_obj.reduction_file_name)
				subgame_obj.stub(:set_input_file).with(path_obj.dominance_json_file_name)
				subgame_obj.stub(:set_output_file).with(path_obj.subgame_json_file_name)
				analysis_obj.stub(:add_argument).with(" -sg #{path_obj.subgame_json_file_name} ")
				analysis_obj.should_receive(:add_argument).with(" -nd #{path_obj.dominance_json_file_name} ")
				@setter.instance_variable_get(:@dominance_obj).stub(:set_output_file).with(path_obj.dominance_json_file_name)
				analysis_obj.stub(:set_output_file).with(path_obj.output_file_name)
				@setter.send(:set_up_input_output)
				
			end
		end
	end

end