require 'data_processing'

describe ObservationValidator do
  describe 'validate' do
    let(:symmetry_groups) do
      [double(role: 'Buyer', strategy: 'BidValue', count: 2),
       double(role: 'Seller', strategy: 'Shade1', count: 1),
       double(role: 'Seller', strategy: 'Shade2', count: 1)]
    end
    let(:profile) { double(symmetry_groups: symmetry_groups) }
    let(:path) { 'fake/path' }
    subject { ObservationValidator.new(profile) }

    before do
      file = double(read: file_contents)
      File.should_receive(:open).with(path).and_return(file)
    end

    context 'when everything is valid' do
      let(:file_contents) do
        <<-JSON
          {
            "features": {
              "featureA": 34.0,
              "featureB": [37, 38],
              "featureC": {
                "C1": 40.0, "C2": 42.0
              }
            },
            "players": [
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "payoff": 2992.73,
                "features": {
                  "featureA": null,
                  "featureB": [2.0, 2.1]
                }
              },
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "payoff": 2990.53,
                "features": {
                  "featureA": 0.002,
                  "featureB": [2.0, 2.1]
                }
              },
              {
                "role": "Seller",
                "strategy": "Shade1",
                "payoff": 2929.34,
                "features": {
                  "featureA": 0.003,
                  "featureB": [1.3, 1.7]
                }
              },
              {
                "role": "Seller",
                "strategy": "Shade2",
                "payoff": 2924.44,
                "features": {
                  "featureA": 0.003,
                  "featureB": [1.4, 1.7]
                }
              }
            ]
          }
        JSON
      end
      let(:outcome) do
        {
          'features' => { 'featureA' => 34.0 },
          'extended_features' => {
            'featureB' => [37, 38],
            'featureC' => {
              'C1' => 40.0, 'C2' => 42.0
            }
          },
          'symmetry_groups' => [
            {
              'role' => 'Buyer',
              'strategy' => 'BidValue',
              'players' => [
                {
                  'payoff' => 2992.73,
                  'features' => {},
                  'extended_features' => {
                    'featureA' => nil,
                    'featureB' => [2.0, 2.1]
                  }
                },
                {
                  'payoff' => 2990.53,
                  'features' => { 'featureA' => 0.002 },
                  'extended_features' => { 'featureB' => [2.0, 2.1] }
                }
              ]
            },
            {
              'role' => 'Seller',
              'strategy' => 'Shade1',
              'players' => [
                {
                  'payoff' => 2929.34,
                  'features' => { 'featureA' => 0.003 },
                  'extended_features' => {
                    'featureB' => [1.3, 1.7]
                  }
                }
              ]
            },
            {
              'role' => 'Seller',
              'strategy' => 'Shade2',
              'players' => [
                {
                  'payoff' => 2924.44,
                  'features' => { 'featureA' => 0.003 },
                  'extended_features' => {
                    'featureB' => [1.4, 1.7]
                  }
                }
              ]
            }
          ]
        }
      end

      it { subject.validate(path).should eql(outcome) }

      context 'when there are string numeric payoff values' do
        let(:file_contents) do
          <<-JSON
            {
              "features": {
                "featureA": 34.0,
                "featureB": [37, 38],
                "featureC": {
                  "C1": 40.0, "C2": 42.0
                }
              },
              "players": [
                {
                  "role": "Buyer",
                  "strategy": "BidValue",
                  "payoff": "2992.73",
                  "features": {
                    "featureA": null,
                    "featureB": [2.0, 2.1]
                  }
                },
                {
                  "role": "Buyer",
                  "strategy": "BidValue",
                  "payoff": "2990.53",
                  "features": {
                    "featureA": 0.002,
                    "featureB": [2.0, 2.1]
                  }
                },
                {
                  "role": "Seller",
                  "strategy": "Shade1",
                  "payoff": "2929.34",
                  "features": {
                    "featureA": 0.003,
                    "featureB": [1.3, 1.7]
                  }
                },
                {
                  "role": "Seller",
                  "strategy": "Shade2",
                  "payoff": "2924.44",
                  "features": {
                    "featureA": 0.003,
                    "featureB": [1.4, 1.7]
                  }
                }
              ]
            }
          JSON
        end

        it 'they get converted to floats' do
          subject.validate(path).should eql(outcome)
        end
      end
    end

    context 'when there are non-numeric payoffs' do
      let(:file_contents) do
        <<-JSON
          {
            "players": [
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "count": 2,
                "payoff": "FAIL"
              },
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "payoff": 2990.53
              },
              {
                "role": "Seller",
                "strategy": "Shade1",
                "payoff": 2929.34
              },
              {
                "role": "Seller",
                "strategy": "Shade2",
                "payoff": 2924.44
              }
            ]
          }
        JSON
      end

      it { expect(subject.validate(path).nil?).to be_true }
    end
  end
end
