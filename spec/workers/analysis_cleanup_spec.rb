require 'spec_helper'

describe AnalysisCleanup do
  describe '#perform' do
  	let(:cleaner) {double ("cleaner")}
  	let(:game_id) {1}
  	let(:analysis_id) {1}
  	before do
      AnalysisCleaner.should_receive(:new).with(game_id, analysis_id).and_return(cleaner)
    end
    it 'delegates cleaning of the AnalysisCleaner' do
      cleaner.should_receive(:clean)
      AnalysisCleanup.new.perform(game_id, analysis_id)
    end
  end
end
