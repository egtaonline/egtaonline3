require 'spec_helper'

describe AnalysisRequeuer do
  describe '#perform' do
    let(:analysis) { double('analysis') }
    let(:submitter) {double ("submitter")}
  
    it 'requeues analysis' do
 
      AnalysisSubmitter.should_receive(:new).with(analysis).and_return(submitter)
      submitter.should_receive(:submit)

      AnalysisRequeuer.new.perform(analysis)
    end
  end
end