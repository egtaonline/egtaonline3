require 'backend/observation_validator'

describe ObservationValidator do
  describe 'validate' do
    let(:symmetry_groups) do
      [double(role: 'Buyer', strategy: 'BidValue', count: 2),
       double(role: 'Seller', strategy: 'Shade1', count: 1),
       double(role: 'Seller', strategy: 'Shade2', count: 1)]
    end
    let(:profile){ double(symmetry_groups: symmetry_groups) }
    let(:path){ 'fake/path' }

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
            "symmetry_groups": [
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "players": [
                  {
                    "payoff": 2992.73,
                    "features": {
          				    "featureA": 0.001,
          				    "featureB": [2.0, 2.1]
          			    }
          			  },
            			{
            			  "payoff": 2990.53,
              			"features": {
              				"featureA": 0.002,
              				"featureB": [2.0, 2.1]
            			  }
                  }
                ]
              },
              {
                "role": "Seller",
                "strategy": "Shade1",
                "players": [
                  {
                    "payoff": 2929.34,
          			    "features": {
          				    "featureA": 0.003,
          				    "featureB": [1.3, 1.7]
          			    }
          			  }
                ]
              },
              {
                "role": "Seller",
                "strategy": "Shade2",
                "players": [
          			  {
          			    "payoff": 2924.44,
          			    "features": {
          				    "featureA": 0.003,
          				    "featureB": [1.4, 1.7]
          			    }
          			  }
                ]
              }
            ]
          }
        JSON
      end
      let(:outcome) do
        {
          "features" => {
            "featureA" => 34.0,
            "featureB" => [37, 38],
            "featureC" => {
              "C1" => 40.0, "C2" => 42.0
            }
          },
          "symmetry_groups" => [
            {
              "role" => 'Buyer',
              "strategy" => 'BidValue',
              "players" => [
                {
                  "payoff" => 2992.73,
        			    "features" => {
        				    "featureA" => 0.001,
        				    "featureB" => [2.0, 2.1]
        			    }
        			  },
        			  {
        			    "payoff" => 2990.53,
          			  "features" => {
          				  "featureA" => 0.002,
          				  "featureB" => [2.0, 2.1]
          			  }
        			  }
              ]
            },
            {
              "role" => 'Seller',
              "strategy" => 'Shade1',
              "players" => [
                "payoff" => 2929.34,
        			  "features" => {
        				  "featureA" => 0.003,
        				  "featureB" => [1.3, 1.7]
        			  }
              ]
            },
            {
              "role" => 'Seller',
              "strategy" => 'Shade2',
              "players" => [
        			  "payoff" => 2924.44,
        			  "features" => {
        				  "featureA" => 0.003,
        				  "featureB" => [1.4, 1.7]
        			  }
              ]
            }
          ]
        }
      end

      it { ObservationValidator.validate(profile, path).should eql(outcome) }

      context 'when the data does not match the profile' do
        let(:symmetry_groups) do
          [double(role: 'Buyer', strategy: 'BidValue', count: 2),
           double(role: 'Seller', strategy: 'Shade2', count: 1),
           double(role: 'Seller', strategy: 'Shade3', count: 1)]
         end

         it { ObservationValidator.validate(profile, path).should == nil }
      end

      context 'when there is extra content' do
        let(:file_contents) do
          <<-JSON
            {
              "extra": "content",
              "features": {
                "featureA": 34.0,
                "featureB": [37, 38],
                "featureC": {
                  "C1": 40.0, "C2": 42.0
                }
              },
              "symmetry_groups": [
                {
                  "role": "Buyer",
                  "strategy": "BidValue",
                  "count": 2,
                  "players": [
                    {
                      "payoff": 2992.73,
                      "features": {
            				    "featureA": 0.001,
            				    "featureB": [2.0, 2.1]
            			    }
            			  },
              			{
              			  "payoff": 2990.53,
                			"features": {
                				"featureA": 0.002,
                				"featureB": [2.0, 2.1]
              			  },
              			  "other_extra": 23
                    }
                  ]
                },
                {
                  "role": "Seller",
                  "strategy": "Shade1",
                  "players": [
                    {
                      "payoff": 2929.34,
            			    "features": {
            				    "featureA": 0.003,
            				    "featureB": [1.3, 1.7]
            			    }
            			  }
                  ]
                },
                {
                  "role": "Seller",
                  "strategy": "Shade2",
                  "players": [
            			  {
            			    "payoff": 2924.44,
            			    "features": {
            				    "featureA": 0.003,
            				    "featureB": [1.4, 1.7]
            			    }
            			  }
                  ]
                }
              ]
            }
          JSON
        end

        it 'is filtered out' do
          ObservationValidator.validate(profile, path).should eql(outcome)
        end
      end

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
              "symmetry_groups": [
                {
                  "role": "Buyer",
                  "strategy": "BidValue",
                  "players": [
                    {
                      "payoff": "2992.73",
                      "features": {
            				    "featureA": 0.001,
            				    "featureB": [2.0, 2.1]
            			    }
            			  },
              			{
              			  "payoff": "2990.53",
                			"features": {
                				"featureA": 0.002,
                				"featureB": [2.0, 2.1]
              			  }
                    }
                  ]
                },
                {
                  "role": "Seller",
                  "strategy": "Shade1",
                  "players": [
                    {
                      "payoff": "2929.34",
            			    "features": {
            				    "featureA": 0.003,
            				    "featureB": [1.3, 1.7]
            			    }
            			  }
                  ]
                },
                {
                  "role": "Seller",
                  "strategy": "Shade2",
                  "players": [
            			  {
            			    "payoff": "2924.44",
            			    "features": {
            				    "featureA": 0.003,
            				    "featureB": [1.4, 1.7]
            			    }
            			  }
                  ]
                }
              ]
            }
          JSON
        end

        it 'they get converted to floats' do
          ObservationValidator.validate(profile, path).should eql(outcome)
        end
      end
    end

    context 'when there are non-numeric payoffs' do
      let(:file_contents) do
        <<-JSON
          {
            "symmetry_groups": [
              {
                "role": "Buyer",
                "strategy": "BidValue",
                "count": 2,
                "players": [
                  {
                    "payoff": "FAIL"
          			  },
            			{
            			  "payoff": 2990.53
                  }
                ]
              },
              {
                "role": "Seller",
                "strategy": "Shade1",
                "count": 1,
                "players": [
                  {
                    "payoff": 2929.34
          			  }
                ]
              },
              {
                "role": "Seller",
                "strategy": "Shade2",
                "count": 1,
                "players": [
          			  {
          			    "payoff": 2924.44
          			  }
                ]
              }
            ]
          }
        JSON
      end

      it { ObservationValidator.validate(profile, path).should == nil }
    end
  end
end