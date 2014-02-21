require 'spec_helper'

describe DprScheduler do
  describe '#profile_space' do
    it 'returns an array of profiles consistent with the current roles' do
      scheduler = FactoryGirl.create(:dpr_scheduler, size: 7)
      ProfileAssociator.stub(:perform_async)
      scheduler.add_role('Role1', 3, 2)
      scheduler.add_role('Role2', 4, 3)
      scheduler.add_strategy('Role1', 'A')
      scheduler.add_strategy('Role1', 'B')
      scheduler.add_strategy('Role2', 'C')
      scheduler.add_strategy('Role2', 'D')
      scheduler.reload.profile_space.sort.should == ['Role1: 3 A; Role2: 4 C', 'Role1: 3 A; Role2: 3 C, 1 D', 'Role1: 3 A; Role2: 2 C, 2 D', 'Role1: 3 A; Role2: 1 C, 3 D', 'Role1: 3 A; Role2: 4 D',
                                                     'Role1: 1 A, 2 B; Role2: 4 C', 'Role1: 2 A, 1 B; Role2: 4 C', 'Role1: 1 A, 2 B; Role2: 3 C, 1 D', 'Role1: 2 A, 1 B; Role2: 3 C, 1 D',
                                                     'Role1: 2 A, 1 B; Role2: 2 C, 2 D', 'Role1: 2 A, 1 B; Role2: 1 C, 3 D', 'Role1: 1 A, 2 B; Role2: 1 C, 3 D',
                                                     'Role1: 1 A, 2 B; Role2: 4 D', 'Role1: 2 A, 1 B; Role2: 4 D',
                                                     'Role1: 3 B; Role2: 4 C', 'Role1: 3 B; Role2: 3 C, 1 D', 'Role1: 3 B; Role2: 2 C, 2 D', 'Role1: 3 B; Role2: 1 C, 3 D', 'Role1: 3 B; Role2: 4 D'].sort
    end

    it 'returns the right profiles even in tricky cases' do
      scheduler = FactoryGirl.create(:dpr_scheduler, size: 22)
      ProfileAssociator.stub(:perform_async)
      scheduler.add_role('Role1', 21, 6)
      scheduler.add_role('Role2', 1, 1)
      scheduler.add_strategy('Role1', 'B')
      scheduler.add_strategy('Role1', 'A')
      scheduler.add_strategy('Role2', 'C')
      scheduler.reload.profile_space.sort.should == ['Role1: 21 A; Role2: 1 C', 'Role1: 20 A, 1 B; Role2: 1 C', 'Role1: 18 A, 3 B; Role2: 1 C', 'Role1: 17 A, 4 B; Role2: 1 C', 'Role1: 16 A, 5 B; Role2: 1 C',
                                                     'Role1: 14 A, 7 B; Role2: 1 C', 'Role1: 13 A, 8 B; Role2: 1 C', 'Role1: 12 A, 9 B; Role2: 1 C', 'Role1: 11 A, 10 B; Role2: 1 C',
                                                     'Role1: 9 A, 12 B; Role2: 1 C', 'Role1: 8 A, 13 B; Role2: 1 C', 'Role1: 7 A, 14 B; Role2: 1 C', 'Role1: 5 A, 16 B; Role2: 1 C',
                                                     'Role1: 4 A, 17 B; Role2: 1 C', 'Role1: 3 A, 18 B; Role2: 1 C', 'Role1: 1 A, 20 B; Role2: 1 C', 'Role1: 21 B; Role2: 1 C'].sort
    end
  end
end