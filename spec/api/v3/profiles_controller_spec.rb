require 'spec_helper'

describe 'ProfilesController' do
  let(:user) { create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'GET /api/v3/profiles/:id' do
    let!(:profile){ create(:profile) }
    let(:url){ "/api/v3/profiles/#{profile.id}" }

    it 'returns the appropriate json from a ProfilePresenter' do
      get "#{url}.json", auth_token: token, granularity: 'full'
      response.status.should == 200
      response.body.should == ProfilePresenter.new(profile).to_json(
        granularity: 'full')
    end
  end
end