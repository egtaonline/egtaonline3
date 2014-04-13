require 'spec_helper'

describe ProfileScheduler do
  describe '#schedule' do
    context 'profile is not scheduled' do
      let(:profile) { create(:profile, assignment: 'All: 2 A') }
      let(:inactive_scheduler) do
        create(:generic_scheduler,
               simulator_instance: profile.simulator_instance,
               active: false, observations_per_simulation: 25)
      end
      let(:active_scheduler) do
        create(:generic_scheduler,
               simulator_instance: profile.simulator_instance,
               active: true, observations_per_simulation: 25)
      end
      # Needs to be tested with timing
      it 'respects active' do
        inactive_scheduler.add_role('All', 2)
        active_scheduler.add_role('All', 2)
        inactive_scheduler.add_profile(profile.assignment, 25)
        active_scheduler.add_profile(profile.assignment, 10)
        ProfileScheduler.new.perform(profile.id)
        expect(Simulation.last.size).to equal(10)
      end
    end
  end
end
