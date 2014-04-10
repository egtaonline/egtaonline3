require 'spec_helper'

describe HierarchicalScheduler do
  let(:scheduler) { create(:hierarchical_scheduler, size: 7) }

  describe '#profile_space' do
    it 'returns an array of profiles consistent with the current roles' do
      ProfileAssociator.stub(:perform_async)
      scheduler.add_role('Role1', 3, 2)
      scheduler.add_role('Role2', 4, 2)
      scheduler.add_strategy('Role1', 'A')
      scheduler.add_strategy('Role1', 'B')
      scheduler.add_strategy('Role2', 'C')
      scheduler.add_strategy('Role2', 'D')
      expect(scheduler.reload.profile_space.sort)
        .to  eq(['Role1: 3 A; Role2: 4 C', 'Role1: 3 A; Role2: 2 C, 2 D',
                 'Role1: 3 A; Role2: 4 D', 'Role1: 3 B; Role2: 4 C',
                 'Role1: 3 B; Role2: 2 C, 2 D', 'Role1: 3 B; Role2: 4 D',
                 'Role1: 2 A, 1 B; Role2: 4 C',
                 'Role1: 2 A, 1 B; Role2: 2 C, 2 D',
                 'Role1: 2 A, 1 B; Role2: 4 D'].sort)
    end
  end
end
