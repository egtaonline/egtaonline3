require 'analysis'

describe SubgameArgumentSetter do
	let(:input_dir){"input_dir"}
	let(:input_file){"input_file"}
	let(:game) { double(subgames: "") }
	let(:subgame) {""}

	let(:non_empty_subgame) {"{Foo:Bar}"}
	let(:non_empty_game) {double(subgames: "{Foo:Bar}")}
	
	before(:each) do
		@setter = SubgameArgumentSetter.new
	end
	describe "#prepare_input" do
		

		context "when the subgame json field is empty" do			
			it "sets the subgame exist var to false" do				
				game.should_receive(:subgames).and_return(subgame)
				subgame.should_receive(:blank?).and_return(true)			
				@setter.prepare_input(game, input_dir, input_file).should be_false
			end
		end

		context "when subgame json field is not empty" do       		
     		
     		it "sets the subgame exist var to true" do
        		non_empty_game.should_receive(:subgames).and_return(non_empty_subgame)
        		non_empty_subgame.should_receive(:blank?).and_return(false)
        		non_empty_subgame_json = double("json")
        		non_empty_subgame.stub(:to_json).and_return(non_empty_subgame_json)
        		f = double('file')

		        f.stub(:write).with(non_empty_subgame_json)
		        File.stub(:open).with(
		          "#{input_dir}/#{input_file}", 'w', 0770).and_yield(f)
     			@setter.prepare_input(non_empty_game, input_dir, input_file).should be_true
     		end

     		it "writes the subgame json into the right input" do
     			non_empty_game.should_receive(:subgames).and_return(non_empty_subgame)
        		non_empty_subgame.should_receive(:blank?).and_return(false)
        		non_empty_subgame_json = double("json")
        		non_empty_subgame.should_receive(:to_json).and_return(non_empty_subgame_json)
        		f = double('file')

		        f.should_receive(:write).with(non_empty_subgame_json)
		        File.should_receive(:open).with(
		          "#{input_dir}/#{input_file}", 'w', 0770).and_yield(f)
     			@setter.prepare_input(non_empty_game, input_dir, input_file)
     		end
		end
	end
	describe "#run_with_option" do
		context "when subgame json file doesn't exit" do 
			it "runs without argument k" do
				input_file_name = "foo"
				output_file_name = "bar"
				expect(@setter.run_with_option(input_file_name,output_file_name)).to eq("python Subgames.py detect < foo > bar")
			end
		end
		context "when subgame json file exits" do 
			it "runs with argument k and subgame json file name" do
				input_file_name = "foo"
				output_file_name = "bar"
				subgame_json_file_name = "subgame.json"
				
				non_empty_game.stub(:subgames).and_return(non_empty_subgame)
        		non_empty_subgame.stub(:blank?).and_return(false)
        		non_empty_subgame_json = double("json")
        		non_empty_subgame.stub(:to_json).and_return(non_empty_subgame_json)
        		f = double('file')

		        f.stub(:write).with(non_empty_subgame_json)
		        File.stub(:open).with(
		          "#{input_dir}/#{input_file}", 'w', 0770).and_yield(f)
     			@setter.prepare_input(non_empty_game, input_dir, input_file)

				expect(@setter.run_with_option(input_file_name,output_file_name, subgame_json_file_name)).to eq("python Subgames.py detect -k subgame.json < foo > bar")
			end
		end
	end

	describe "#set_up_remote" do
		input_file_path = "input_file_path"
		script_path = "script_path"
		work_dir = "work_dir"
		
		context "when subgame json file doesn't exit" do 
			it "only needs to copy the script to remote folder" do
				expect(@setter.set_up_remote(input_file_path,script_path, work_dir)).to eq("cp -r script_path/Subgames.py work_dir")
			end
		end

		context "when subgame json file exits" do
			it "copys both the script and the subgame json file" do
				
				non_empty_game.stub(:subgames).and_return(non_empty_subgame)
        		non_empty_subgame.stub(:blank?).and_return(false)
        		non_empty_subgame_json = double("json")
        		non_empty_subgame.stub(:to_json).and_return(non_empty_subgame_json)
        		f = double('file')

		        f.stub(:write).with(non_empty_subgame_json)
		        File.stub(:open).with(
		          "#{input_dir}/#{input_file}", 'w', 0770).and_yield(f)
     			@setter.prepare_input(non_empty_game, input_dir, input_file)

				expect(@setter.set_up_remote(input_file_path,script_path, work_dir)).to eq(("cp -r script_path/Subgames.py work_dir\n" \
               "cp -r input_file_path work_dir\n"))
			end
		end
	end

	describe "#get_output" do
		it "gets the right output file back" do
			work_dir = "work_dir"
			filename = "filename"
			local_dir = "local_dir"
			expect(@setter.get_output(work_dir, filename, local_dir)).to eq("cp -r work_dir/filename local_dir")

		end
	end
end