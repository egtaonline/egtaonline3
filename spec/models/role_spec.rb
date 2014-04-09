require 'spec_helper'

describe Role do
  describe '#count_is_acceptable' do
    let(:role_owner){ create(:game_scheduler) }
    it 'passes when reduced count <= count <= unassigned_player_count' do
      role = role_owner.roles.build(name: 'All', count: 2, reduced_count: 2)
      role.valid?.should == true
    end

    it 'fails when the reduced count > count' do
      role = role_owner.roles.build(name: 'All', count: 1, reduced_count: 2)
      role.valid?.should == false
    end

    it 'fails when count > unassigned_player_count' do
      role = role_owner.roles.build(name: 'All',
        count: 3, reduced_count: 2)
      role.valid?.should == false
    end
  end
end
