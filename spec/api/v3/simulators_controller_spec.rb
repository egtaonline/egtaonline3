require 'spec_helper'

describe 'SimulatorsController' do
  let(:user) { create(:approved_user) }
  let(:token) { user.authentication_token }
  let(:role) { 'RoleA' }
  let(:strategy) { 'Strategy1' }
  let(:missing_sim) { 'the Simulator you were looking for could not be found' }
  let(:missing_role) { 'the Role you were looking for could not be found' }

  describe 'POST /api/v3/simulators/:id/add_strategy' do
    let(:url) { '/api/v3/simulators/1/add_strategy' }
    let(:query) { { auth_token: token, role: role, strategy: strategy } }

    context 'when the simulator does not exist' do
      it 'returns an appropriate 404' do
        post "#{url}.json", query
        expect(response.status).to eql(404)
        expect(response.body).to eql({ error: missing_sim }.to_json)
      end
    end
    context 'when the simulator exists' do
      let!(:simulator) { create(:simulator, id: 1) }
      context 'but the role does not exist' do
        it 'returns an appropriate 422' do
          post "#{url}.json", query
          response.status.should eql(422)
          expect(response.body).to eql({ error: missing_role }.to_json)
        end
      end
      context 'and the role exists' do
        before do
          simulator.add_role(role)
        end

        it 'returns a 204 and adds the strategy to the simulator' do
          post "#{url}.json", query
          response.status.should eql(204)
          expect(simulator.reload.role_configuration[role])
            .to include(strategy)
        end
      end
    end
  end

  describe 'POST /api/v3/simulators/:id/remove_strategy' do
    let(:url) { '/api/v3/simulators/1/remove_strategy' }
    let(:query) { { auth_token: token, role: role, strategy: strategy } }

    context 'when the simulator does not exist' do
      it 'returns an appropriate 404' do
        post "#{url}.json", query
        response.status.should eql(404)
        expect(response.body).to eql({ error: missing_sim }.to_json)
      end
    end
    context 'when the simulator exists' do
      let!(:simulator) { create(:simulator, id: 1) }
      context 'but the role does not exist' do
        it 'returns an appropriate 422' do
          post "#{url}.json", query
          response.status.should eql(422)
          expect(response.body).to eql({ error: missing_role }.to_json)
        end
      end
      context 'and the role exists' do
        before do
          simulator.add_role(role)
        end

        it 'returns a 204 and removes the strategy from the simulator' do
          post "#{url}.json", query
          response.status.should eql(204)
          expect(simulator.reload.role_configuration[role])
          .to_not include(strategy)
        end
      end
    end
  end

  describe 'POST /api/v3/simulators/:id/add_role' do
    let(:url) { '/api/v3/simulators/1/add_role' }
    let(:size) { 2 }
    let(:query) { { auth_token: token, role: role } }

    context 'when the simulator does not exist' do
      it 'returns an appropriate 404' do
        post "#{url}.json", query
        response.status.should eql(404)
        expect(response.body).to eql({ error: missing_sim }.to_json)
      end
    end
    context 'when the simulator exists' do
      let!(:simulator) { create(:simulator, id: 1) }

      it 'returns an error for misformatted roles' do
        post "#{url}.json", auth_token: token, role: '123.f!3#'
        response.status.should eql(422)
        expect(response.body).to eql(
          { error: 'only letters, numbers, or underscores ' \
            'are allowed in Role name' }.to_json)
      end

      it 'returns a 204 and adds the role to the simulator' do
        post "#{url}.json", query
        response.status.should eql(204)
        expect(simulator.reload.role_configuration[role]).to eq([])
      end
    end
  end

  describe 'POST /api/v3/simulators/:id/remove_role' do
    let(:url) { '/api/v3/simulators/1/remove_role' }
    let(:query) { { auth_token: token, role: role } }

    context 'when the simulator does not exist' do
      it 'returns an appropriate 404' do
        post "#{url}.json", query
        response.status.should eql(404)
        expect(response.body).to eql({ error: missing_sim }.to_json)
      end
    end
    context 'when the simulator exists' do
      let!(:simulator) { create(:simulator, id: 1) }

      before do
        simulator.add_role(role)
      end

      it 'returns a 204 and removes the role from the simulator' do
        post "#{url}.json", query
        response.status.should eql(204)
        expect(simulator.reload.role_configuration[role]).to eq(nil)
      end
    end
  end

  describe 'GET /api/v3/simulators' do
    let!(:simulator) { create(:simulator) }
    let!(:simulator2) { create(:simulator) }
    let(:url) { '/api/v3/simulators' }

    it 'returns summary info for the available games' do
      get "#{url}.json", auth_token: token
      expect(response.status).to eq(200)
      expect(response.body)
        .to eq({ simulators: [simulator.reload, simulator2.reload] }.to_json)
    end
  end

  describe 'GET /api/v3/simulators/:id' do
    let!(:simulator) { create(:simulator, id: 1) }
    let(:url) { '/api/v3/simulators/1' }

    it 'responds with the simulator' do
      get "#{url}.json", auth_token: token
      expect(response.status).to eq(200)
      expect(response.body).to eq(simulator.reload.to_json)
    end
  end
end
