require 'spec_helper'

describe 'SchedulersController' do
  let(:user) { create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'GET /api/v3/schedulers/:id' do
    let!(:scheduler) { create(:game_scheduler, id: 1) }
    let(:url) { '/api/v3/schedulers/1' }

    it 'returns the appropriate json from a GenericSchedulerPresenter' do
      get "#{url}.json", auth_token: token, granularity: 'summary'
      expect(response.status).to eq(200)
      expect(response.body)
        .to eq(SchedulerPresenter.new(scheduler.reload).to_json(
          granularity: 'summary'))
    end
  end
end
