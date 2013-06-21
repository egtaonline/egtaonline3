require 'spec_helper'

describe "Profiles" do
  describe "GET /profiles/:id", type: :feature do
    before do
      sign_in
    end

    it "should show that profile" do
      profile = FactoryGirl.create(:profile, :with_observations)
      visit profile_path(profile.id)
      page.should have_content(profile.assignment)
      page.should have_content(profile.symmetry_groups.last.payoff_sd)
    end
  end
end