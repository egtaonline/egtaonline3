require 'spec_helper'

describe 'GamesController' do
  let(:user) { FactoryGirl.create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'POST /api/v3/games/:id/add_strategy' do
    let(:url){"/api/v3/games/1/add_strategy"}
    let(:role){ 'RoleA' }
    let(:strategy){ 'Strategy1' }
    let(:query){ { auth_token: token, role: role, strategy: strategy } }

    context 'when the game does not exist' do
      it "returns an appropriate 404" do
        post "#{url}.json", query
        response.status.should eql(404)
        response.body.should eql({error:
          "the Game you were looking for could" +
          " not be found"}.to_json)
      end
    end
    context 'when the game exists' do
      let!(:game){ FactoryGirl.create(:game, id: 1) }
      context 'but the role does not exist' do
        it "returns an appropriate 424" do
          post "#{url}.json", query
          response.status.should eql(424)
          response.body.should eql({error:
            "the Role you were looking for could" +
            " not be found"}.to_json)
        end
      end
      context 'and the role exists' do
        before do
          game.simulator.add_role(role)
          game.add_role(role, game.size)
        end
        context 'but the strategy does not exist on the simulator' do
          it "returns an appropriate 424" do
            post "#{url}.json", query
            response.status.should eql(424)
            response.body.should eql({error:
              "the Strategy you wished to add was not found on the Game's" +
              " Simulator"}.to_json)
          end
        end
        context 'and the strategy exists on the simulator' do
          before do
            game.simulator.add_strategy(role, strategy)
          end

          it 'returns a 204 and adds the strategy to the game' do
            post "#{url}.json", query
            response.status.should eql(204)
            game.roles.find_by(name: role).strategies.should include(strategy)
          end
        end
      end
    end
  end
  #
  # remove_strategy_api_v3_game POST   /api/v3/games/:id/remove_strategy(.:format)                       api/v3/games#remove_strategy
  #        add_role_api_v3_game POST   /api/v3/games/:id/add_role(.:format)                              api/v3/games#add_role
  #     remove_role_api_v3_game POST   /api/v3/games/:id/remove_role(.:format)                           api/v3/games#remove_role
  #                api_v3_games GET    /api/v3/games(.:format)                                           api/v3/games#index
  #                 api_v3_game GET    /api/v3/games/:id(.:format)
end