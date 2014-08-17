require 'analysis'

describe ScriptsArgumentSetter do
	let(:analysis_obj){double("analysis_obj")}
	let(:reduction_obj){double ("reduction_obj")}
	let(:subgame_obj){double("subgame_obj")}
	let(:game){ double ("game")}
	let(:path_obj){double("path object")}


	context "when reduction and subgame options are checked" do
		before(:each) do
			@setter = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,subgame_obj)				
			@setter.set_path(path_obj)
		end

		describe "#set_path" do
			it "sets the right paht_finder object" do
				@setter = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,subgame_obj)				
				@setter.set_path(path_obj).should == path_obj
			end
		end

		describe "#prepare_input" do
			local_input_path = "local/analysis/game-id/in"
			input_file_name = "game-id-analysis-time.json"
			local_subgame_path = "local/analysis/game-id/subgame"
			subgame_json_file_name = "subgame.json"

			it "prepares the analysis script input" do
				
				path_obj.should_receive(:local_input_path).and_return(local_input_path)
				path_obj.should_receive(:input_file_name).and_return(input_file_name)
				analysis_obj.should_receive(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.stub(:local_subgame_path).and_return(local_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				subgame_obj.stub(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				@setter.prepare_input(game)
			end
			
			it "prepares the subgame script input" do
				
				path_obj.stub(:local_input_path).and_return(local_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				analysis_obj.stub(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.should_receive(:local_subgame_path).and_return(local_subgame_path)
				path_obj.should_receive(:subgame_json_file_name).and_return(subgame_json_file_name)
				subgame_obj.should_receive(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				
				@setter.prepare_input(game)
			end
		end

		describe "#set_up_remote_command" do
			it "sets up the remote for each of the script" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"
				remote_subgame_path = "remote_subgame_path"
				subgame_json_file_name = "subgame_json_file_name"
				subgame_script_path = "subgame_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				reduction_set_up_command = "reduction_set_up_command"
				subgame_set_up_command = "subgame_set_up_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:reduction_script_path).and_return(reduction_script_path)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:subgame_script_path).and_return(subgame_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.stub(:join).with(remote_subgame_path,subgame_json_file_name).and_return("remote_subgame_path/subgame_json_file_name")
				analysis_obj.should_receive(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.should_receive(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.should_receive(:set_up_remote_script).with(reduction_script_path, work_dir).and_return(reduction_set_up_command)
				subgame_obj.should_receive(:set_up_remote).with("remote_subgame_path/subgame_json_file_name",subgame_script_path, work_dir ).and_return(subgame_set_up_command)
				expect(@setter.set_up_remote_command).to eq("module load python/2.7.5\n" \
				   "mkdir $JOB_ID\n" \
	               "analysis_set_up_remote_script_command\n" \
	               "analysis_set_up_remote_input_command\n\n" \
	               "reduction_set_up_command\n" \
	               "subgame_set_up_command\n" \
	               "cd $JOB_ID\n" \
	               "export PYTHONPATH=$PYTHONPATH:scripts_path\n")				
			end

			it "gets the right paths" do
				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"
				remote_subgame_path = "remote_subgame_path"
				subgame_json_file_name = "subgame_json_file_name"
				subgame_script_path = "subgame_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				reduction_set_up_command = "reduction_set_up_command"
				subgame_set_up_command = "subgame_set_up_command"

				path_obj.should_receive(:analysis_script_path).and_return(analysis_script_path)
				path_obj.should_receive(:remote_input_path).and_return(remote_input_path)
				path_obj.should_receive(:input_file_name).and_return(input_file_name)
				path_obj.should_receive(:reduction_script_path).and_return(reduction_script_path)
				path_obj.should_receive(:remote_subgame_path).and_return(remote_subgame_path)
				path_obj.should_receive(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.should_receive(:subgame_script_path).and_return(subgame_script_path)
				path_obj.should_receive(:scripts_path).and_return(scripts_path)
				path_obj.should_receive(:working_dir).and_return(work_dir)

				File.should_receive(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.should_receive(:join).with(remote_subgame_path,subgame_json_file_name).and_return("remote_subgame_path/subgame_json_file_name")
				analysis_obj.stub(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.stub(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.stub(:set_up_remote_script).with(reduction_script_path, work_dir).and_return(reduction_set_up_command)
				subgame_obj.stub(:set_up_remote).with("remote_subgame_path/subgame_json_file_name",subgame_script_path, work_dir ).and_return(subgame_set_up_command)
				@setter.set_up_remote_command
			end
		end

		describe "#get_script_command" do
			it "runs three scripts" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_reduction_command = "running_reduction_command"
				running_subgame_command = "running_subgame_command"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.stub(reduction_file_name).exactly(3).times.and_return(reduction_file_name)
				path_obj.stub(subgame_json_file_name).exactly(3).times.and_return(subgame_json_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				reduction_obj.should_receive(:run_with_option).with(input_file_name,reduction_file_name).and_return(running_reduction_command)
				subgame_obj.should_receive(:run_with_option).with(reduction_file_name,subgame_json_file_name,subgame_json_file_name).and_return(running_subgame_command)
				analysis_obj.should_receive(:run_with_option).with(reduction_file_name, output_file_name, "-sg subgame_json_file_name").and_return(running_analysis_command)

				expect(@setter.get_script_command).to eq("running_reduction_command\n" \
				   "running_subgame_command\n" \
	               "running_analysis_command\n")
			end

			it "gets the right paths" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_reduction_command = "running_reduction_command"
				running_subgame_command = "running_subgame_command"
				running_analysis_command = "running_analysis_command"

				path_obj.should_receive(input_file_name).and_return(input_file_name)
				path_obj.should_receive(reduction_file_name).exactly(3).times.and_return(reduction_file_name)
				path_obj.should_receive(subgame_json_file_name).exactly(3).times.and_return(subgame_json_file_name)
				path_obj.should_receive(output_file_name).and_return(output_file_name)
				
				reduction_obj.stub(:run_with_option).with(input_file_name,reduction_file_name).and_return(running_reduction_command)
				subgame_obj.stub(:run_with_option).with(reduction_file_name,subgame_json_file_name,subgame_json_file_name).and_return(running_subgame_command)
				analysis_obj.stub(:run_with_option).with(reduction_file_name, output_file_name, "-sg subgame_json_file_name").and_return(running_analysis_command)

				@setter.get_script_command
			end
		end

		describe "#clean_up_remote_command" do
			it "gets the analysis and subgame script outputs back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				subgame_json_file_name = "subgame_json_file_name"
				remote_subgame_path = "remote_subgame_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"
				subgame_clean_up = "subgame_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)

				analysis_obj.should_receive(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)
				subgame_obj.should_receive(:get_output).with(work_dir,subgame_json_file_name, remote_subgame_path).and_return(subgame_clean_up)

				expect(@setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
				   "subgame_clean_up\n" \
	               "rm -rf $JOB_ID\n")

			end
		end

		describe "#clean_up_remote_command" do
			it "gets the right paths" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				subgame_json_file_name = "subgame_json_file_name"
				remote_subgame_path = "remote_subgame_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"
				subgame_clean_up = "subgame_clean_up"

				path_obj.should_receive(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.should_receive(:output_file_name).and_return(output_file_name)
				path_obj.should_receive(:remote_output_path).and_return(remote_output_path)
				path_obj.should_receive(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.should_receive(:remote_subgame_path).and_return(remote_subgame_path)

				analysis_obj.stub(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)
				subgame_obj.stub(:get_output).with(work_dir,subgame_json_file_name, remote_subgame_path).and_return(subgame_clean_up)

				@setter.clean_up_remote_command

			end
		end
	end

	context "when reduction is checked,  subgame option is not" do
		before(:each) do
			@setter = ScriptsArgumentSetter.new(analysis_obj,reduction_obj,nil)				
			@setter.set_path(path_obj)
		end

		describe "#prepare_input" do
			local_input_path = "local/analysis/game-id/in"
			input_file_name = "game-id-analysis-time.json"
			local_subgame_path = "local/analysis/game-id/subgame"

			it "prepares the analysis script input" do
				
				path_obj.should_receive(:local_input_path).and_return(local_input_path)
				path_obj.should_receive(:input_file_name).and_return(input_file_name)
				analysis_obj.should_receive(:prepare_input).with(game,local_input_path,input_file_name)
				path_obj.stub(:local_subgame_path).and_return(local_subgame_path)
				@setter.prepare_input(game)
			end
			
			it "should not prepare the subgame script input" do
				
				path_obj.stub(:local_input_path).and_return(local_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				analysis_obj.stub(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.should_not_receive(:local_subgame_path)
				path_obj.should_not_receive(:subgame_json_file_name)
				subgame_obj.should_not_receive(:prepare_input)
				
				@setter.prepare_input(game)
			end

		end

		describe "#set_up_remote_command" do
			it "sets up the remote for analysis and reduction scripts" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				reduction_set_up_command = "reduction_set_up_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:reduction_script_path).and_return(reduction_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				analysis_obj.should_receive(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.should_receive(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.should_receive(:set_up_remote_script).with(reduction_script_path, work_dir).and_return(reduction_set_up_command)
				expect(@setter.set_up_remote_command).to eq("module load python/2.7.5\n" \
				   "mkdir $JOB_ID\n" \
	               "analysis_set_up_remote_script_command\n" \
	               "analysis_set_up_remote_input_command\n\n" \
	               "reduction_set_up_command\n" \
	               "\n" \
	               "cd $JOB_ID\n" \
	               "export PYTHONPATH=$PYTHONPATH:scripts_path\n")				
			end

			it "should not set up remote for subgame" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"
				remote_subgame_path = "remote_subgame_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"
				subgame_json_file_name = "subgame_json_file_name"
				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				reduction_set_up_command = "reduction_set_up_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:reduction_script_path).and_return(reduction_script_path)
				path_obj.should_not_receive(:remote_subgame_path)
				path_obj.should_not_receive(:subgame_json_file_name)
				path_obj.should_not_receive(:subgame_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.should_not_receive(:join).with(remote_subgame_path,subgame_json_file_name)
				analysis_obj.stub(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.stub(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.stub(:set_up_remote_script).with(reduction_script_path, work_dir).and_return(reduction_set_up_command)
				subgame_obj.should_not_receive(:set_up_remote)
				@setter.set_up_remote_command			
			end

		end
		describe "#get_script_command" do
			it "runs analysis and reduction scripts" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				output_file_name = "output_file_name"
				running_reduction_command = "running_reduction_command"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.stub(reduction_file_name).exactly(3).times.and_return(reduction_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				reduction_obj.should_receive(:run_with_option).with(input_file_name,reduction_file_name).and_return(running_reduction_command)
				analysis_obj.should_receive(:run_with_option).with(reduction_file_name, output_file_name).and_return(running_analysis_command)

				expect(@setter.get_script_command).to eq("running_reduction_command\n" \
	               "running_analysis_command\t\t\n")
			end

			it "should not run subgame script" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_reduction_command = "running_reduction_command"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.stub(reduction_file_name).exactly(3).times.and_return(reduction_file_name)
				path_obj.should_not_receive(subgame_json_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				reduction_obj.stub(:run_with_option).with(input_file_name,reduction_file_name).and_return(running_reduction_command)
				subgame_obj.should_not_receive(:run_with_option).with(reduction_file_name,subgame_json_file_name,subgame_json_file_name)
				analysis_obj.stub(:run_with_option).with(reduction_file_name, output_file_name).and_return(running_analysis_command)

				expect(@setter.get_script_command).to eq("running_reduction_command\n" \
	               "running_analysis_command\t\t\n")
			end
		end

		describe "#clean_up_remote_command" do
			it "gets the analysis outputs back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)

				analysis_obj.should_receive(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)

				expect(@setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
				   "\n" \
	               "rm -rf $JOB_ID\n")

			end
			it "should not get the subgame outputs back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				subgame_json_file_name = "subgame_json_file_name"
				remote_subgame_path = "remote_subgame_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)
				path_obj.should_not_receive(:subgame_json_file_name)
				path_obj.should_not_receive(:remote_subgame_path)

				analysis_obj.should_receive(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)
				subgame_obj.should_not_receive(:get_output).with(work_dir,subgame_json_file_name, remote_subgame_path)

				@setter.clean_up_remote_command
			end
		end
	end

	context "when subgame is checked,  reduction option is not" do
		before(:each) do
			@setter = ScriptsArgumentSetter.new(analysis_obj, nil, subgame_obj)				
			@setter.set_path(path_obj)
		end

		describe "#prepare_input" do
			local_input_path = "local/analysis/game-id/in"
			input_file_name = "game-id-analysis-time.json"
			local_subgame_path = "local/analysis/game-id/subgame"
			subgame_json_file_name = "subgame.json"

			it "prepares the subgame script input" do
				
				path_obj.stub(:local_input_path).and_return(local_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				analysis_obj.stub(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.should_receive(:local_subgame_path).and_return(local_subgame_path)
				path_obj.should_receive(:subgame_json_file_name).and_return(subgame_json_file_name)
				subgame_obj.should_receive(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				
				@setter.prepare_input(game)
			end
			it "prepares the analysis script input" do
				
				path_obj.stub(:local_input_path).and_return(local_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				analysis_obj.should_receive(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.stub(:local_subgame_path).and_return(local_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				subgame_obj.stub(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				@setter.prepare_input(game)
			end			
		end

		describe "#set_up_remote_command" do
			it "sets up the remote for subgame script" do
				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				remote_subgame_path = "remote_subgame_path"
				subgame_json_file_name = "subgame_json_file_name"
				subgame_script_path = "subgame_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				subgame_set_up_command = "subgame_set_up_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:subgame_script_path).and_return(subgame_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.stub(:join).with(remote_subgame_path,subgame_json_file_name).and_return("remote_subgame_path/subgame_json_file_name")
				analysis_obj.should_receive(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.should_receive(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				subgame_obj.should_receive(:set_up_remote).with("remote_subgame_path/subgame_json_file_name",subgame_script_path, work_dir ).and_return(subgame_set_up_command)
				expect(@setter.set_up_remote_command).to eq("module load python/2.7.5\n" \
				   "mkdir $JOB_ID\n" \
	               "analysis_set_up_remote_script_command\n" \
	               "analysis_set_up_remote_input_command\n\n" \
	               "\n" \
	               "subgame_set_up_command\n" \
	               "cd $JOB_ID\n" \
	               "export PYTHONPATH=$PYTHONPATH:scripts_path\n")				
			end

			it "should not set up the remote for reduction script" do
				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"
				remote_subgame_path = "remote_subgame_path"
				subgame_json_file_name = "subgame_json_file_name"
				subgame_script_path = "subgame_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				subgame_set_up_command = "subgame_set_up_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.should_not_receive(:reduction_script_path)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:subgame_script_path).and_return(subgame_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.stub(:join).with(remote_subgame_path,subgame_json_file_name).and_return("remote_subgame_path/subgame_json_file_name")
				analysis_obj.stub(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.stub(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.should_not_receive(:set_up_remote_script).with(reduction_script_path, work_dir)
				subgame_obj.stub(:set_up_remote).with("remote_subgame_path/subgame_json_file_name",subgame_script_path, work_dir ).and_return(subgame_set_up_command)
				@setter.set_up_remote_command			
			end

		
		end

		describe "#get_script_command" do
			it "runs subgame and analysis scripts" do
				input_file_name = "input_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_subgame_command = "running_subgame_command"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.stub(subgame_json_file_name).exactly(3).times.and_return(subgame_json_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				subgame_obj.should_receive(:run_with_option).with(input_file_name,subgame_json_file_name,subgame_json_file_name).and_return(running_subgame_command)
				analysis_obj.should_receive(:run_with_option).with(input_file_name, output_file_name, "-sg subgame_json_file_name").and_return(running_analysis_command)

				expect(@setter.get_script_command).to eq(
				   "running_subgame_command\n" \
	               "running_analysis_command\n")
			end

			it "should not run reduction script" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_subgame_command = "running_subgame_command"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.should_not_receive(reduction_file_name)
				path_obj.stub(subgame_json_file_name).exactly(3).times.and_return(subgame_json_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				reduction_obj.should_not_receive(:run_with_option).with(input_file_name,reduction_file_name)
				subgame_obj.should_receive(:run_with_option).with(input_file_name,subgame_json_file_name,subgame_json_file_name).and_return(running_subgame_command)
				analysis_obj.should_receive(:run_with_option).with(input_file_name, output_file_name, "-sg subgame_json_file_name").and_return(running_analysis_command)
				@setter.get_script_command
			end
		end

		describe "#clean_up_remote_command" do
			it "gets the analysis and subgame script outputs back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				subgame_json_file_name = "subgame_json_file_name"
				remote_subgame_path = "remote_subgame_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"
				subgame_clean_up = "subgame_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)

				analysis_obj.should_receive(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)
				subgame_obj.should_receive(:get_output).with(work_dir,subgame_json_file_name, remote_subgame_path).and_return(subgame_clean_up)

				expect(@setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
				   "subgame_clean_up\n" \
	               "rm -rf $JOB_ID\n")
			end
		end
	end

	context "when subgame and reduction are both disabled" do
		before(:each) do
			@setter = ScriptsArgumentSetter.new(analysis_obj, nil, nil)				
			@setter.set_path(path_obj)
		end

		describe "#prepare_input" do
			local_input_path = "local/analysis/game-id/in"
			input_file_name = "game-id-analysis-time.json"
			local_subgame_path = "local/analysis/game-id/subgame"
			subgame_json_file_name = "subgame.json"

			it "prepares the analysis script input" do
				
				path_obj.should_receive(:local_input_path).and_return(local_input_path)
				path_obj.should_receive(:input_file_name).and_return(input_file_name)
				analysis_obj.should_receive(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.stub(:local_subgame_path).and_return(local_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				@setter.prepare_input(game)
			end
			
			it "should not prepare the subgame script input" do
				
				path_obj.stub(:local_input_path).and_return(local_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				analysis_obj.stub(:prepare_input).with(game,local_input_path,input_file_name)

				path_obj.should_not_receive(:local_subgame_path)
				path_obj.should_not_receive(:subgame_json_file_name)
				subgame_obj.should_not_receive(:prepare_input).with(game,local_subgame_path, subgame_json_file_name)
				
				@setter.prepare_input(game)
			end
		end

		describe "#set_up_remote_command" do
			it "sets up the remote for analysis script" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
				

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				analysis_obj.should_receive(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.should_receive(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				expect(@setter.set_up_remote_command).to eq("module load python/2.7.5\n" \
				   "mkdir $JOB_ID\n" \
	               "analysis_set_up_remote_script_command\n" \
	               "analysis_set_up_remote_input_command\n\n" \
	               "\n" \
	               "\n" \
	               "cd $JOB_ID\n" \
	               "export PYTHONPATH=$PYTHONPATH:scripts_path\n")				
			end
			it "should not set up remote for reduction script" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				reduction_script_path = "reduction_script_path"

				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"
			

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:reduction_script_path).and_return(reduction_script_path)
			
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				analysis_obj.stub(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.stub(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				reduction_obj.should_not_receive(:set_up_remote_script).with(reduction_script_path, work_dir)
				@setter.set_up_remote_command		
			end

			it "should not set up remote for subgame script" do

				work_dir = "$JOB_ID"
				remote_input_path = "remote_input_path"
				input_file_name = "input_file_name"
				remote_subgame_path = "remote_subgame_path"
				subgame_json_file_name = "subgame_json_file_name"
				subgame_script_path = "subgame_script_path"
				analysis_script_path = "analysis_script_path"
				scripts_path = "scripts_path"

				analysis_set_up_remote_script_command = "analysis_set_up_remote_script_command"
				analysis_set_up_remote_input_command = "analysis_set_up_remote_input_command"

				path_obj.stub(:analysis_script_path).and_return(analysis_script_path)
				path_obj.stub(:remote_input_path).and_return(remote_input_path)
				path_obj.stub(:input_file_name).and_return(input_file_name)
				path_obj.stub(:remote_subgame_path).and_return(remote_subgame_path)
				path_obj.stub(:subgame_json_file_name).and_return(subgame_json_file_name)
				path_obj.stub(:subgame_script_path).and_return(subgame_script_path)
				path_obj.stub(:scripts_path).and_return(scripts_path)
				path_obj.stub(:working_dir).and_return(work_dir)

				File.stub(:join).with(remote_input_path, input_file_name).and_return("remote_input_path/input_file_name")
				File.should_not_receive(:join).with(remote_subgame_path,subgame_json_file_name)
				analysis_obj.stub(:set_up_remote_script).with(analysis_script_path,work_dir).and_return(analysis_set_up_remote_script_command)
				analysis_obj.stub(:set_up_remote_input).with("remote_input_path/input_file_name",work_dir).and_return(analysis_set_up_remote_input_command)
				subgame_obj.should_not_receive(:set_up_remote).with("remote_subgame_path/subgame_json_file_name",subgame_script_path, work_dir )
				@setter.set_up_remote_command		
			end
		end

		describe "#get_script_command" do
			it "runs analysis script" do
				input_file_name = "input_file_name"
				output_file_name = "output_file_name"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				analysis_obj.should_receive(:run_with_option).with(input_file_name, output_file_name).and_return(running_analysis_command)

				expect(@setter.get_script_command).to eq(
	               "running_analysis_command")
			end
			it "should not run reduction script" do
				input_file_name = "input_file_name"
				reduction_file_name = "reduction_file_name"
				output_file_name = "output_file_name"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.should_not_receive(reduction_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				reduction_obj.should_not_receive(:run_with_option).with(input_file_name,reduction_file_name)
				analysis_obj.stub(:run_with_option).with(input_file_name, output_file_name).and_return(running_analysis_command)
				@setter.get_script_command
			end

			it "should not run subgame script" do
				input_file_name = "input_file_name"
				subgame_json_file_name = "subgame_json_file_name"
				output_file_name = "output_file_name"
				running_analysis_command = "running_analysis_command"

				path_obj.stub(input_file_name).and_return(input_file_name)
				path_obj.should_not_receive(subgame_json_file_name)
				path_obj.stub(output_file_name).and_return(output_file_name)
				
				subgame_obj.should_not_receive(:run_with_option).with(input_file_name,subgame_json_file_name,subgame_json_file_name)
				analysis_obj.stub(:run_with_option).with(input_file_name, output_file_name).and_return(running_analysis_command)
				@setter.get_script_command
			end
		end

		describe "#clean_up_remote_command" do
			it "gets the analysis script output back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)

				analysis_obj.should_receive(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)

				expect(@setter.clean_up_remote_command).to eq("analysis_clean_up\n" \
				   "\n" \
	               "rm -rf $JOB_ID\n")

			end

			it "should not get the subgame script output back" do
				work_dir = "$JOB_ID"
				remote_output_path = "remote_output_path"
				subgame_json_file_name = "subgame_json_file_name"
				remote_subgame_path = "remote_subgame_path"
				output_file_name = "output_file_name"
				analysis_clean_up = "analysis_clean_up"

				path_obj.stub(:working_dir).exactly(3).times.and_return(work_dir)
				path_obj.stub(:output_file_name).and_return(output_file_name)
				path_obj.stub(:remote_output_path).and_return(remote_output_path)
				path_obj.should_not_receive(:subgame_json_file_name)
				path_obj.should_not_receive(:remote_subgame_path)

				analysis_obj.stub(:get_output).with(work_dir, output_file_name, remote_output_path).and_return(analysis_clean_up)
				subgame_obj.should_not_receive(:get_output).with(work_dir,subgame_json_file_name, remote_subgame_path)
				@setter.clean_up_remote_command

			end
		end
	end
end