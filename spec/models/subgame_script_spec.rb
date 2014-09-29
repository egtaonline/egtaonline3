require 'spec_helper'

describe SubgameScript do
  before(:each) do
  	@analysis = create(:analysis, :running_status)
  end

  describe 'validate' do
  	it 'validates the model' do
  		@analysis.create_subgame_script
  		@analysis.subgame_script.should be_valid
  	end
  end

  describe '#get_command' do
  	context 'no subgame saved' do
  		it 'makes command for running the script' do
  			@analysis.create_subgame_script
  			com = "python Subgames.py detect < ./out/#{@analysis.game.id}-dominance-#{@analysis.id}.json >"\
  			" ./out/#{@analysis.game.id}-subgame-#{@analysis.id}.json"

  			expect(@analysis.subgame_script.get_command).to eq(com)
  		end
  	end

  	context 'with saved subgame' do
  		it 'makes command for running with previous saved subgame' do
  			@analysis.create_subgame_script(subgame: 1.to_json)
  			com = "python Subgames.py detect -k #{@analysis.game.id}-subgame-#{@analysis.id}.json < ./out/#{@analysis.game.id}-dominance-#{@analysis.id}.json >"\
  			" ./out/#{@analysis.game.id}-subgame-#{@analysis.id}.json"
  			expect(@analysis.subgame_script.get_command).to eq(com)
  		end
  	end
  end

  describe '#set_up_remote' do
  	it 'sets the remote working directory' do
  		@analysis.create_subgame_script
  		com = "cp -r /nfs/wellman_ls/GameAnalysis/Subgames.py /tmp/${PBS_JOBID}"
  		expect(@analysis.subgame_script.set_up_remote).to eq(com)
  	end
  end

end
