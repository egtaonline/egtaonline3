require 'spec_helper'

describe GameScheduler do
  describe '#profile_space' do
    it 'returns an array of profiles consistent with the current roles' do
      ProfileAssociator.stub(:perform_async)
      scheduler = create(:game_scheduler, size: 3)
      scheduler.add_role('A', 2)
      scheduler.add_role('B', 1)
      scheduler.add_strategy('A', 'S2')
      scheduler.add_strategy('B', 'S3')
      scheduler.add_strategy('B', 'S1')
      expect(scheduler.reload.profile_space.sort)
        .to eq(['A: 2 S2; B: 1 S3', 'A: 2 S2; B: 1 S1'].sort)
    end
  end
end
