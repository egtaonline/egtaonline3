require 'spec_helper'

describe 'Profiles' do
  describe 'GET /profiles/:id', type: :feature do
    before do
      sign_in
    end

    it 'should show that profile' do
      profile = create(:profile, :with_observations)
      profile.symmetry_groups.last.update_attributes(adjusted_payoff: 235.26)
      visit profile_path(profile.id)
      expect(page).to have_content(profile.assignment)
      expect(page).to have_content(profile.symmetry_groups.last.payoff_sd)
      expect(page).to have_content(235.26)
    end
  end
end
