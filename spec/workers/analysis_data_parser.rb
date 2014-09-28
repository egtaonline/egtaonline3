require 'spec_helper'

describe AnalysisDataParser do
  describe '#perform' do
    # let(:analysis) { double(status: "running") }
    let(:processor) {double ("processor")}

    let(:analysis){create(:analysis, :running_status)}

    it 'processes files for specified analysis' do      
      AnalysisDataProcessor.should_receive(:new).with(analysis).and_return(processor)
      processor.should_receive(:process_files)
      subject.perform(analysis.id)
    end
  end
end