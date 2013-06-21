require 'spec_helper'

describe "HierarchicalSchedulers" do

  describe "GET /hierarchical_schedulers", type: :feature do
    before do
      sign_in
    end

    it "should show only hierarchical schedulers" do
      s1 = FactoryGirl.create(:generic_scheduler)
      s2 = FactoryGirl.create(:hierarchical_scheduler)
      visit hierarchical_schedulers_path
      page.should have_content("Hierarchical Schedulers")
      page.should_not have_content(s1.name)
      page.should have_content(s2.name)
    end
  end
end