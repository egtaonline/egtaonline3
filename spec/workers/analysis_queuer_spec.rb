require 'spec_helper'

describe AnalysisQueuer do
  describe '#perform' do
    let(:analyses) { [double('analysis1'), double('analysis2')] }
    let(:analysis_preparer) {double("analysis_preparer")}
    let(:submitter) {double ("submitter")}
    before do
      Analysis.should_receive(:queueable).and_return(analyses)
    end

    it 'prepares each analysis and submit each one' do

      analyses.each do |analysis|
        AnalysisPreparer.should_receive(:new).with(analysis).and_return(analysis_preparer)
        analysis_preparer.should_receive(:prepare_analysis)
        AnalysisSubmitter.should_receive(:new).with(analysis).and_return(submitter)
        submitter.should_receive(:submit)
      end

      AnalysisQueuer.new.perform
    end
  end
end