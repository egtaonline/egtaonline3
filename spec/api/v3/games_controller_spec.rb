require 'spec_helper'

describe 'GamesController' do
  let(:user) { create(:approved_user) }
  let(:token) { user.authentication_token }
  let(:role){ 'RoleA' }
  let(:strategy){ 'Strategy1' }

  context 'when a game exists' do
    let!(:game){ FactoryGirl.create(:game) }
    describe 'POST /api/v3/games/:id/add_strategy' do
      let(:url){"/api/v3/games/#{game.id}/add_strategy"}
      let(:query){ { auth_token: token, role: role, strategy: strategy } }

      context 'but the role does not exist' do
        it "returns an appropriate 422" do
          post "#{url}.json", query
          response.status.should eql(422)
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
          it "returns an appropriate 422" do
            post "#{url}.json", query
            response.status.should eql(422)
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

    describe 'POST /api/v3/games/:id/remove_strategy' do
      let(:url){"/api/v3/games/#{game.id}/remove_strategy"}
      let(:query){ { auth_token: token, role: role, strategy: strategy } }

      context 'but the role does not exist' do
        it "returns an appropriate 422" do
          post "#{url}.json", query
          response.status.should eql(422)
          response.body.should eql({error:
            "the Role you were looking for could" +
            " not be found"}.to_json)
        end
      end
      context 'and the role exists' do
        before do
          game.simulator.add_role(role)
          game.add_role(role, game.size)
          game.add_strategy(role, strategy)
        end

        it 'returns a 204 and removes the strategy from the game' do
          post "#{url}.json", query
          response.status.should eql(204)
          game.roles.find_by(name: role).strategies.should_not(
            include(strategy))
        end
      end
    end

    describe 'GET /api/v3/games/:id' do
      let(:url){ "/api/v3/games/#{game.id}" }

      it 'returns the appropriate json from a GamePresenter' do
        get "#{url}.json", auth_token: token, granularity: 'summary'
        response.status.should == 200
        response.body.should == GamePresenter.new(game).to_json(
          granularity: 'summary')
      end
    end
  end

  context 'when a game does not exist' do
    let(:query){ { auth_token: token, role: role, strategy: strategy } }

    ["/api/v3/games/0/add_strategy",
     "/api/v3/games/0/remove_strategy"].each do |url|
      it "returns an appropriate 404" do
        post "#{url}.json", query
        response.status.should eql(404)
        response.body.should eql({error:
          "the Game you were looking for could" +
          " not be found"}.to_json)
      end
    end
  end

  describe 'GET /api/v3/games' do
    let!(:game){ FactoryGirl.create(:game) }
    let!(:game2){ FactoryGirl.create(:game) }
    let(:url){ '/api/v3/games' }

    it 'returns summary info for the available games' do
      get "#{url}.json", auth_token: token
      response.status.should == 200
      response.body.should == { games: [game.reload, game2.reload] }.to_json
    end
  end
end