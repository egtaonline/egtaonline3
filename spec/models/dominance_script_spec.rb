require 'spec_helper'

describe DominanceScript do
  before(:each) do
  	@analysis = create(:analysis, :running_status)
  end

  describe 'validate' do
  	it 'validates the model' do
  		@analysis.create_dominance_script
  		@analysis.dominance_script.should be_valid
  	end
  end

  describe '#get_command' do
  	context 'no reduction script' do
  		it 'makes command for running the script' do
  			@analysis.create_dominance_script
  			com = "python Dominance.py < #{@analysis.game.id}-analysis-#{@analysis.id}.json >"\
  			" ./out/#{@analysis.game.id}-dominance-#{@analysis.id}.json"

  			expect(@analysis.dominance_script.get_command).to eq(com)
  		end
  	end

  	context 'with reduction script' do
  		it 'makes command for running with reduction input' do
  			params = {
  				mode: "test_mode",
  				reduced_number: "test_number" 
  			}
  			@analysis.create_reduction_script(params)
  			@analysis.create_dominance_script
  			com = "python Dominance.py < ./out/#{@analysis.game.id}-reduced-#{@analysis.id}.json >"\
  			" ./out/#{@analysis.game.id}-dominance-#{@analysis.id}.json"
  			expect(@analysis.dominance_script.get_command).to eq(com)
  		end
  	end
  end

  describe '#set_up_remote' do
  	it 'sets the remote working directory' do
  		@analysis.create_dominance_script
		com = "cp -r /nfs/wellman_ls/game_analysis/Dominance.py /tmp/${PBS_JOBID}"
  		expect(@analysis.dominance_script.set_up_remote).to eq(com)
  	end
  end

end
