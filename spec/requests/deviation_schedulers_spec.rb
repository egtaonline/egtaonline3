require 'spec_helper'

describe "DeviationSchedulers" do
  shared_examples "a deviation scheduler on requests" do
    before do
      sign_in
    end

    let(:klass){ described_class.to_s }
    let(:scheduler) do
      FactoryGirl.create(klass.underscore.to_sym)
    end

    context "POST /schedulers/:scheduler_id/roles/:role/deviating_strategies",
      type: :feature do
      before do
        scheduler.simulator.add_strategy('All', 'DeviousStrategy')
        scheduler.add_role('All', scheduler.size)
      end
      it "should add the strategy to the deviating strategy set" do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Add Deviating Strategy'
        page.should have_content("DeviousStrategy")
        scheduler.reload.roles.first.deviating_strategies.should include(
          "DeviousStrategy")
        scheduler.roles.first.strategies.should_not include("DeviousStrategy")
      end
    end

    context "DELETE /schedulers/:scheduler_id/roles/:role/deviating_strategies",
      type: :feature do
      before do
        scheduler.simulator.add_strategy('All', 'DeviousStrategy')
        scheduler.add_role('All', scheduler.size)
        scheduler.add_deviating_strategy('All', 'DeviousStrategy')
      end
      it "should delete the strategy from the deviating strategy set" do
        visit "/#{klass.tableize}/#{scheduler.id}"
        click_on 'Remove Deviating Strategy'
        scheduler.reload.roles.first.deviating_strategies.should_not include(
          "DeviousStrategy")
      end
    end
  end

  DEVIATION_SCHEDULER_CLASSES.each do |s_class|
    describe s_class do
      it_behaves_like "a deviation scheduler on requests"
    end
  end
end