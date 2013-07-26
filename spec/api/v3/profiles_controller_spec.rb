require 'spec_helper'

describe 'ProfilesController' do
  let(:user) { FactoryGirl.create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'GET /api/v3/profiles/:id' do
    let!(:profile){ FactoryGirl.create(:profile, id: 1) }
    let(:url){ '/api/v3/profiles/1' }

    it 'returns the appropriate json from a ProfilePresenter' do
      get "#{url}.json", auth_token: token, granularity: 'full'
      response.status.should == 200
      response.body.should == ProfilePresenter.new(profile).to_json(
        granularity: 'full')
    end
  end
end