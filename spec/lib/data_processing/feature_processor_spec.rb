require 'data_processing'

describe FeatureProcessor do
  describe '.parse' do
    let(:features) { { 'first' => 1, 'second' => 0.5, 'third' => '-23' } }
    let(:extended_features) do
      { 'nest' => { 'nested' => 21 },
        'non-numeric' => true, 'non-numeric_string' => 'Hello' }
    end

    context 'when feature map is empty' do
      it 'returns empty maps' do
        expect(FeatureProcessor.parse({}))
          .to eq('features' => {}, 'extended_features' => {})
        expect(FeatureProcessor.parse(nil))
          .to eq('features' => {}, 'extended_features' => {})
      end
    end

    context 'when only control-variate style features are present' do
      it 'leaves extended features empty' do
        expect(FeatureProcessor.parse(features))
          .to eq('features' => features, 'extended_features' => {})
      end
    end

    context 'when only non-control-variate style features are present' do
      it 'leaves features empty' do
        expect(FeatureProcessor.parse(extended_features))
          .to eq('features' => {}, 'extended_features' => extended_features)
      end
    end

    context 'when a mixture of features are present' do
      it 'separates them appropriately' do
        expect(FeatureProcessor.parse(features.merge(extended_features)))
          .to eq('features' => features,
                 'extended_features' => extended_features)
      end
    end
  end
end
