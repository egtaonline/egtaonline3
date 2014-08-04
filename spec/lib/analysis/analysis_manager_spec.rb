require 'analysis'
describe AnalysisManager do
  let(:reduced_mode) { 'DR'}
  let(:time) {double ('time')}
  let(:game_id){ 1 }
  let(:enable_reduced){ 'enable_reduced'}
  let(:regret){2}
  let(:dist){3}
  let(:support){4}
  let(:converge){5}
  let(:iters){6}
  let(:reduced_num_array){[2,3]}
  let(:roles_count){2}
  let(:email){'test@test.com'}
  let(:path_finder){double('path finder')}
  let(:hour){4}
  let(:day){3}
  let(:min){2}
  let(:analysis_manager) do
    AnalysisManager.new(game_id,enable_reduced,regret,dist,support,converge,iters,reduced_num_array,roles_count,reduced_mode, email, day, hour, min)
  end

  before do
    AnalysisPathFinder.should_receive(:new).with(game_id, time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder)
  end

  describe '#prepare_data' do
  	pending
  	# before do
  	# 	before do
  	# 		let(:game){double(id:game_id)}
  	# 		game.should_receive(:to_json)
  	# 		let(:game_presenter){double('game presenter')}
  	# 		File.should_receive(:join).with("path_finder.local_input_path","path_finder.input_file_name")
  	# 		let(:file){double('file')}
  	# 	end
  	# 	GamePresenter.should_receive(new).with(game_presenter)
  	# end
    # it 'prepares the input file and creates folder non-exist' do
      # let(:game_presenter){double('game presenter')}
      # FileUtils.should_receive(:mkdir_p).with(path_finder.local_output_path,mode: 0770)
      # FileUtils.should_receive(:mkdir_p).with(path_finder.local_input_path,mode: 0770)
      # FileUtils.should_receive(:mkdir_p).with(path_finder.local_pbs_path,mode: 0770)
      # FileUtils.should_receive(:mv).with(game_presenter,file)
    # end
  end

  describe '#set_script_arguments' do
  	pending
  	# context 'when reduction of game is enabled'
  	# let(:reduced_script_arguments){""}
  	# it 'runs the reduction script and the analysis script' do
    	# ScriptsArgumentSetter.should_receive(scriptCommand).with(enable_reduced,reduced_num_array,roles_count,reduced_mode,path_finder, regret, dist,support,converge, iters).and_return(reduced_script_arguments)
    # end
    # context 'when reduction of game is disabled'
  	# let(:reduced_script_arguments){""}
  	# it 'runs the analysis script' do
    	# ScriptsArgumentSetter.should_receive(scriptCommand).with(enable_reduced,reduced_num_array,roles_count,reduced_mode,path_finder, regret, dist,support,converge, iters).and_return(reduced_script_arguments)
    # end
  end

  describe '#create_pbs' do
  	pending
    # AnalysisPbsFormatter.should_receive(new).with(path_finder,running_script_command,email,walltime)
  end

  describe '#submit_job' do
	pending   
  end
end
