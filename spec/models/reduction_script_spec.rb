require 'spec_helper'

describe ReductionScript do
  before(:each) do
  	@params = {
  		mode: "test_mode",
  		reduced_number: "test_number" 
  	}

  	@analysis = create(:analysis, :running_status)
  	@analysis.create_reduction_script(@params)
  end

  describe 'ensures a valid model' do
  	it 'ensure the model is valid' do
	  	@analysis.reduction_script.should be_valid
	end
  end

  describe '#get_command' do
  	it 'make command for running script' do
  		com = "python Reductions.py -input "\
  		"#{@analysis.game.id}-analysis-#{@analysis.id}.json "\
  		"-output ./out/#{@analysis.game.id}-reduced-#{@analysis.id}.json "\
  		"#{@analysis.reduction_script.mode} #{@analysis.reduction_script.reduced_number}"

  		expect(@analysis.reduction_script.get_command).to eq(com)
  	end
  end

  describe '#set_up_remote' do
  	it 'sets up remote working dir with files' do
  		com = "cp -r /nfs/wellman_ls/GameAnalysis/Reductions.py /tmp/${PBS_JOBID}"
  		expect(@analysis.reduction_script.set_up_remote).to eq(com)
  	end
  end	
end
