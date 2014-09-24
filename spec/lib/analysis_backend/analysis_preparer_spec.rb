# require 'analysis_backend'

# describe AnalysisPreparer do 
# 	describe "#prepare_analysis"  do
# 		let(subgame_script){double(:script=> "script")}
# 		let(:analysis){double("analysis", 
# 			:game_id => 5, 
# 			:id => 5, 
# 			:enable_subgame => true,
# 			:)}
# 		let(:path_finder) {double('path_finder',
# 			:local_data_path => "abc",
# 			:local_input_path => "abc",
# 			:local_pbs_path => "abs",
# 			:local_output_path => "abc")}
# 		before do
# 			AnalysisPathFinder.should_receive(:new).with(analysis.id.to_s, analysis.game_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder)
# 		end
# 		it 'prepares the files for analysis' do
# 			file_manager = FileManager.new(path_finder)
# 			file_manager.should_receive(:created_folder)

# 			preparer = AnalysisPreparer.new(analysis)
# 			preparer.prepare_analysis
# 		end
# 	end
# end