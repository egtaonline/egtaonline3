require 'spec_helper'

describe 'Schedulers' do
  before do
    sign_in
  end

  describe 'GET /schedulers', type: :feature do
    let!(:scheduler1){ FactoryGirl.create(:game_scheduler) }
    let!(:scheduler2){ FactoryGirl.create(:generic_scheduler) }

    it 'returns all schedulers' do
      visit '/schedulers'
      page.should have_content(scheduler1.name)
      page.should have_content(scheduler2.name)
    end
  end

  shared_examples "a scheduler on configuration manipulation" do
    let(:klass){ described_class.to_s.tableize }

    describe "POST /schedulers/update_configuration",
      type: :feature, js: true do
      let(:first_simulator){ FactoryGirl.create(:simulator) }
      let(:second_simulator){ FactoryGirl.create(:simulator) }

      before do
        first_simulator.update_attributes(
          configuration: { "Parm1"=>"2","Parm2"=>"3" })
        second_simulator.update_attributes(
          configuration: { "Parm2"=>"7","Parm3"=>"6" })
      end

      context 'when creating a new scheduler' do
        before do
          visit "/#{klass}/new"
        end
        it "updates parameter info" do
          select first_simulator.fullname, from: :selector_simulator_id
          first_simulator.configuration.each do |k,v|
            page.should have_content(k)
          end
          select second_simulator.fullname, from: :selector_simulator_id
          second_simulator.configuration.each do |k,v|
            page.should have_content(k)
          end
        end
      end
    end
  end

  shared_examples "a scheduler on index pages" do
    let(:klass){ described_class.to_s.tableize }

    describe "GET /#{described_class.to_s.tableize}", type: :feature do
      let!(:scheduler) do
        FactoryGirl.create(described_class.to_s.underscore.to_sym)
      end
      it "should shows only #{described_class}s" do
        unless described_class == GenericScheduler
          other_scheduler = FactoryGirl.create(:generic_scheduler)
        else
          other_scheduler = FactoryGirl.create(:game_scheduler)
        end
        visit "/#{klass}"
        page.should have_content(described_class.to_s.titleize)
        page.should_not have_content(other_scheduler.name)
        page.should have_content(scheduler.name)
      end
    end
  end

  shared_examples "a scheduler on deletion" do
    let(:klass){ described_class.to_s.tableize }

    describe "DELETE /schedulers/:id", js: true, type: :feature do
      let!(:scheduler) do
        FactoryGirl.create(described_class.to_s.underscore.to_sym)
      end
      it "should shows only #{described_class}s" do
        visit "/#{klass}"
        click_on "Destroy"
        Scheduler.count.should == 0
      end
    end
  end

  SCHEDULER_CLASSES.each do |s_class|
    describe s_class do
      it_behaves_like "a scheduler on configuration manipulation"
      it_behaves_like "a scheduler on index pages"
      it_behaves_like "a scheduler on deletion"
    end
  end
end