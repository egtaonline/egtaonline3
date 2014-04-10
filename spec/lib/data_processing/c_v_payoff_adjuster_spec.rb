require 'data_processing'

describe CVPayoffAdjuster do
  describe '.adjust' do
    let(:payoff) { 50.0 }
    let(:observation_features) { {} }
    let(:observation_cvs) { [] }
    let(:player_features) { {} }
    let(:player_cvs) { [] }

    context 'when there are no player control variables' do
      context 'and there are no observation control variables' do
        it 'returns the payoff' do
          expect(CVPayoffAdjuster.adjust(
            payoff, observation_features, observation_cvs,
            player_features, player_cvs)).to eq(payoff)
        end
      end
      context 'and there are observation control variables' do
        let(:observation_cvs) do
          [double(name: 'feature1', expectation: 5.0, coefficient: 0.23),
           double(name: 'feature2', expectation: 15.0, coefficient: 1.4)]
        end
        context 'and the features match' do
          let(:observation_features) do
            { 'feature1' => '5.5', 'feature2' => '6.1' }
          end
          it 'performs the correct adjustment' do
            expect(CVPayoffAdjuster.adjust(
              payoff, observation_features, observation_cvs,
              player_features, player_cvs))
                .to eq(payoff + 0.23 * (5.5 - 5.0) + 1.4 * (6.1 - 15.0))
          end
        end
        context 'and the features do not fully match' do
          let(:observation_features) { { 'feature1' => '5.5'  } }
          it 'does not perform an adjustment' do
            expect(CVPayoffAdjuster.adjust(
              payoff, observation_features, observation_cvs,
              player_features, player_cvs)).to eq(payoff)
          end
        end
      end
    end

    context 'when there are player control variables' do
      let(:player_cvs) do
        [double(name: 'pfeature1', expectation: 5.0, coefficient: 0.23),
         double(name: 'pfeature2', expectation: 15.0, coefficient: 1.4)]
      end
      context 'and the features match' do
        let(:player_features) do
          { 'pfeature1' => '4.0', 'pfeature2' => '16.2' }
        end
        context 'and there are no observation control variables' do
          it 'performs the correct adjustment' do
            expect(CVPayoffAdjuster.adjust(
              payoff, observation_features, observation_cvs,
              player_features, player_cvs))
              .to eq(payoff + 0.23 * (4.0 - 5.0) + 1.4 * (16.2 - 15.0))
          end
        end
        context 'and there are control variables and matching features' do
          let(:observation_cvs) do
            [double(name: 'feature1', expectation: 5.0, coefficient: 0.23),
             double(name: 'feature2', expectation: 15.0, coefficient: 1.4)]
          end
          let(:observation_features) do
            { 'feature1' => '5.5', 'feature2' => '6.1' }
          end
          it 'performs the correct adjustment' do
            expect(CVPayoffAdjuster.adjust(
              payoff, observation_features, observation_cvs,
              player_features, player_cvs)).to eq(
                payoff + 0.23 * (4.0 - 5.0) + 1.4 * (16.2 - 15.0) +
                0.23 * (5.5 - 5.0) + 1.4 * (6.1 - 15.0))
          end
        end
      end
      context 'and the features do not match' do
        let(:player_features) { { 'feature3' => '5.5'  } }
        it 'does not perform an adjustment' do
          expect(CVPayoffAdjuster.adjust(
            payoff, observation_features, observation_cvs,
            player_features, player_cvs)).to eq(payoff)
        end
      end
    end
  end
end
