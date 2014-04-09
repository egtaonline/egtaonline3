require 'spec_helper'

describe 'ReductionSchedulers' do
  shared_examples 'a reduction scheduler on requests' do
    before do
      sign_in
    end

    let(:klass) { described_class.to_s }
    let(:scheduler) do
      create(klass.underscore.to_sym, size: 4)
    end

    context 'POST /schedulers/:scheduler_id/roles', type: :feature do
      before do
        scheduler.simulator.add_role('All')
      end
      it 'should add the required role with the correct reduction level' do
        visit "/#{klass.tableize}/#{scheduler.id}"
        fill_in 'role_count', with: 4
        fill_in 'reduced_count', with: 2
        click_on 'Add Role'
        expect(page).to have_content('All 4 2')
        expect(scheduler.reload.roles.first.count).to equal(4)
        expect(scheduler.roles.first.reduced_count).to equal(2)
      end
    end
  end

  REDUCTION_SCHEDULER_CLASSES.each do |s_class|
    describe s_class do
      it_behaves_like 'a reduction scheduler on requests'
    end
  end
end
