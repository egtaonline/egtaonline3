require 'spec_helper'

describe 'GamesController' do
  let(:user) { FactoryGirl.create(:approved_user) }
  let(:token) { user.authentication_token }
  let(:role){ 'RoleA' }
  let(:strategy){ 'Strategy1' }

  describe 'POST /api/v3/games/:id/add_strategy' do
    let(:url){"/api/v3/games/1/add_strategy"}
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

  describe 'POST /api/v3/games/:id/remove_strategy' do
    let(:url){"/api/v3/games/1/remove_strategy"}
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
  end

  describe "POST /api/v3/games/:id/add_role" do
    let(:url){"/api/v3/games/1/add_role"}
    let(:size){ 2 }
    let(:query){ { auth_token: token, role: role, count: size } }

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
      context 'but the role does not exist on the simulator' do
        it "returns an appropriate 424" do
          post "#{url}.json", query
          response.status.should eql(424)
          response.body.should eql({error:
            "the Role you wished to add was not found on the Game's" +
            " Simulator"}.to_json)
        end
      end
      context 'and the role exists on the simulator' do
        before do
          game.simulator.add_role(role)
        end
        context 'but the size is too large' do
          let(:size){ 4 }

          it 'returns the role with error message' do
            post "#{url}.json", query
            response.status.should eql(422)
            response.body.should eql({errors: {count: ["can't be larger than " +
              "the owner's unassigned player count"]}}.to_json)
          end
        end

        context 'and the size is acceptable' do
          it 'returns a 204 and adds the role to the game' do
            post "#{url}.json", query
            response.status.should eql(204)
            game.roles.where(name: role, count: size).count.should == 1
          end
        end
      end
    end
  end

  describe 'GET /api/v3/games/:id' do
    let!(:game){ FactoryGirl.create(:game, id: 1) }
    let(:url){ '/api/v3/games/1' }

    it 'returns the appropriate json from a GamePresenter' do
      get "#{url}.json", auth_token: token, granularity: 'summary'
      response.status.should == 200
      response.body.should == GamePresenter.new(game).to_json(
        granularity: 'summary')
    end
  end

  describe 'GET /api/v3/games' do
    let!(:game){ FactoryGirl.create(:game) }
    let!(:game2){ FactoryGirl.create(:game) }
    let(:url){ '/api/v3/games' }

    it 'returns summary info for the available games' do
      get "#{url}.json", auth_token: token
      response.status.should == 200
      response.body.should == { games: [game, game2] }.to_json
    end
  end
end