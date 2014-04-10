require 'spec_helper'

describe HierarchicalDeviationScheduler do
  let(:scheduler) { create(:hierarchical_deviation_scheduler, size: 7) }

  describe '#profile_space' do
    it 'returns an array of profiles consistent with the current roles' do
      ProfileAssociator.stub(:perform_async)
      scheduler.add_role('Role1', 3, 2)
      scheduler.add_role('Role2', 4, 2)
      scheduler.add_strategy('Role1', 'A')
      scheduler.add_strategy('Role1', 'B')
      scheduler.add_deviating_strategy('Role1', 'E')
      scheduler.add_strategy('Role2', 'C')
      scheduler.add_deviating_strategy('Role2', 'D')
      expect(scheduler.reload.profile_space.sort)
        .to eq(['Role1: 3 A; Role2: 4 C', 'Role1: 3 A; Role2: 2 C, 2 D',
                'Role1: 2 A, 1 E; Role2: 4 C', 'Role1: 3 B; Role2: 4 C',
                'Role1: 3 B; Role2: 2 C, 2 D', 'Role1: 2 B, 1 E; Role2: 4 C',
                'Role1: 2 A, 1 B; Role2: 4 C',
                'Role1: 2 A, 1 B; Role2: 2 C, 2 D'].sort)
    end
  end
end
