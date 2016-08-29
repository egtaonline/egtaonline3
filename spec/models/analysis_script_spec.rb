require 'spec_helper'

describe AnalysisScript do
	before(:each) do 
		@params = {
		regret: 0.1, 
		dist: 0.1,
		support: 0.1,
		converge: 0.2,
		iters: 10,
		points: 6		
		}
	end


  it 'has makes a valid model' do
  	analysis = create(:analysis, :running_status)
  	# create(:analysis_script, analysis_id: analysis.id).should be_valid
  	analysis_script = analysis.create_analysis_script(@params)
  	analysis_script.should be_valid
  end

  describe '#get_command' do
  	context 'if no verbose' do
	  	it 'sets up the get scripts command' do
	  		analysis = create(:analysis, :running_status)
	  	 	analysis_script = analysis.create_analysis_script(@params)
	  		com = "python AnalysisScript.py -r #{@params[:regret]} " \
	  		"-d #{@params[:dist]} -s #{@params[:support]} -c #{@params[:converge]} "\
	  		"-i #{@params[:iters]} -p #{@params[:points]} #{analysis.game.id}"\
	  		"-analysis-#{analysis.id}.json > ./out/#{analysis.game.id}"\
	  		"-analysis-#{analysis.id}.txt"
	  		expect(analysis_script.get_command).to eq(com)
  		end
  	end

  	context 'if verbose' do
  		it 'adds verbose argument to get command' do
	  		@params[:verbose] = true
	  		analysis = create(:analysis, :running_status)
		  	analysis_script = analysis.create_analysis_script(@params)
		  	com = "python AnalysisScript.py -r #{@params[:regret]} " \
		  	"-d #{@params[:dist]} -s #{@params[:support]} -c #{@params[:converge]} "\
		  	"-i #{@params[:iters]} -p #{@params[:points]} --verbose  #{analysis.game.id}"\
		 	"-analysis-#{analysis.id}.json > ./out/#{analysis.game.id}"\
		 	"-analysis-#{analysis.id}.txt"
		  	expect(analysis_script.get_command).to eq(com)
		end
  	end

  	context 'if enable dominance' do
  		it 'adds enable dominance to get command' do
  			@params[:enable_dominance] = true
  			analysis = create(:analysis, :running_status)
		  	analysis_script = analysis.create_analysis_script(@params)
		  	com = "python AnalysisScript.py -r #{@params[:regret]} " \
		  	"-d #{@params[:dist]} -s #{@params[:support]} -c #{@params[:converge]} "\
		  	"-i #{@params[:iters]} -p #{@params[:points]}"\
		  	"  -nd ./out/#{analysis.game.id}-dominance-#{analysis.id}.json   "\
		 	"#{analysis.game.id}-analysis-#{analysis.id}.json > ./out/#{analysis.game.id}"\
		 	"-analysis-#{analysis.id}.txt"
		  	expect(analysis_script.get_command).to eq(com)
  		end	
  	end

  	context 'if reduction script present' do
  		pending "Add for presence of reduction script"
  	end

  	context 'if subgame script present' do
  		pending "Add for presence of subgame script"
  	end
  end

  describe '#set_up_command' do
  	it 'sets up the remote working dir on flux' do
  		analysis = create(:analysis, :running_status)
		analysis_script = analysis.create_analysis_script(@params)
		com = "cp -r /nfs/wellman_ls/game_analysis/AnalysisScript.py /tmp/${PBS_JOBID}"

		expect(analysis_script.set_up_remote).to eq(com)
  	end
  end
end
