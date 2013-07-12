require 'spec_helper'

describe 'SchedulersController' do
  let(:user) { FactoryGirl.create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'GET /api/v3/generic_schedulers/:id' do
    let!(:scheduler){ FactoryGirl.create(:game_scheduler, id: 1) }
    let(:url){ '/api/v3/schedulers/1' }

    it 'returns the appropriate json from a GenericSchedulerPresenter' do
      get "#{url}.json", auth_token: token, granularity: 'summary'
      response.status.should == 200
      response.body.should == SchedulerPresenter.new(scheduler).to_json(
        granularity: 'summary')
    end
  end
end