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
    #
    # it 'returns the right profiles even in tricky cases' do
    #   scheduler = FactoryGirl.create(:dpr_scheduler, size: 8)
    #   ProfileAssociator.stub(:perform_async)
    #   scheduler.add_role('Role1', 7, 4)
    #   scheduler.add_role('Role2', 1, 1)
    #   scheduler.add_strategy('Role1', 'A')
    #   scheduler.add_strategy('Role1', 'B')
    #   scheduler.add_strategy('Role2', 'C')
    #   scheduler.reload.profile_space.sort.should == ['Role1: 7 A; Role2: 1 C', 'Role1: 6 A, 1 B; Role2: 1 C', 'Role1: 5 A, 2 B; Role2: 1 C',
    #                                                  'Role1: 4 A, 3 B; Role2: 1 C', 'Role1: 3 A, 4 B; Role2: 1 C', 'Role1: 1 A, 6 B; Role2: 1 C', 'Role1: 7 B; Role2: 1 C'].sort
    # end
  end
end