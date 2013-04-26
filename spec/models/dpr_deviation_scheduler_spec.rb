require 'spec_helper'

describe DprDeviationScheduler do
  let(:scheduler){ FactoryGirl.create(:dpr_deviation_scheduler, size: 7) }

  describe '#profile_space' do
    it 'returns an array of profiles consistent with the current roles' do
      ProfileAssociator.stub(:new).and_return(double(associate: nil))
      scheduler.add_role('Role1', 3, 2)
      scheduler.add_role('Role2', 4, 3)
      scheduler.add_strategy('Role1', 'A')
      scheduler.add_strategy('Role1', 'B')
      scheduler.add_deviating_strategy('Role1', 'E')
      scheduler.add_strategy('Role2', 'C')
      scheduler.add_deviating_strategy('Role2', 'D')
      scheduler.reload.profile_space.sort.should == ['Role1: 3 A; Role2: 4 C', 'Role1: 1 A, 2 B; Role2: 4 C', 'Role1: 2 A, 1 B; Role2: 4 C', 'Role1: 3 B; Role2: 4 C',
                                                'Role1: 2 A, 1 E; Role2: 4 C', 'Role1: 1 A, 2 E; Role2: 4 C', 'Role1: 1 B, 2 E; Role2: 4 C', 'Role1: 2 B, 1 E; Role2: 4 C',
                                                'Role1: 3 A; Role2: 3 C, 1 D', 'Role1: 2 A, 1 B; Role2: 3 C, 1 D', 'Role1: 1 A, 2 B; Role2: 3 C, 1 D', 'Role1: 3 B; Role2: 3 C, 1 D'].sort
    end
  end
end