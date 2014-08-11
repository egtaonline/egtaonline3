# require 'analysis'
# describe SubgameArgumentSetter do
# 	before(:each) do
# 		@setter = SubgameArgumentSetter.new
# 	end
# 	describe "#prepare_input" do
# 		let(:input){"input"}
# 		let(:output){"output"}
		
# 		context "when the subgame json field is empty" do
# 			let(:game){ double( subgame: "")}
# 			game.should_receive(:subgames).and_return("")
			
# 			it "sets the subgame exist var to false" do
# 				@setter.prepare_input(game, input, output).should be_false
# 			end
# 		end

		# context "when subgame json field is not empty" do
		# 	let(:game){double(subgame:"{foo: bar}")}
		# 	it "write the json into file" do 
		# 	end
		# 	it "sets the subgame exist var to true" do
		# 	end
		# end
	end
	# describe "#set_up_remote_script" do
	# 	let(:script_path) { "bar_s_p"}
	# 	let(:work_dir) { "bar_work"}
	# 	it "copies the  script to the right remote directory" do
	# 		@setter.run_with_option(script_path,work_dir).should == "cp -r bar_s_p/Reductions.py bar_work"
	# 	end
	# end
end