require 'spec_helper'

describe AnalysisChecker do
  describe '#perform' do
    let(:analyses) { [double('analysis1'), double('analysis2')] }
    let(:updatter) {double ("updatter")}
    before do
      Analysis.should_receive(:active).and_return(analyses)
    end

    it 'updates each active analysis' do     
      AnalysisUpdatter.should_receive(:new).and_return(updatter)
      updatter.should_receive(:update_analysis).with(analyses)
      subject.perform
    end
  end
end