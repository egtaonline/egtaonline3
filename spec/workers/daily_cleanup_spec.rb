require 'spec_helper'

describe DailyCleanup do
  let(:stale_simulations) { [] }
  let(:stale_analyses) { [double(game_id: 1, id: 1), double(game_id: 2, id: 2)] }
  let(:finished) { [double('first_simulation'), double('second_simulation')] }
  describe 'perform' do
    before do
      Simulation.should_receive(:stale).twice.and_return(stale_simulations)
      Simulation.should_receive(:recently_finished).and_return(finished)
      Analysis.should_receive(:stale).twice.and_return(stale_analyses)
    end

    it 'deletes old simulations and requeues recently finished' do
      stale_simulations.should_receive(:delete_all)
      stale_analyses.stub(:delete_all)
      stale_analyses.each do |a|
        AnalysisCleanup.stub(:perform_async)
      end
      finished.each do |sim|
        sim.should_receive(:requeue)
      end
      DailyCleanup.new.perform
    end

    it 'deletes old analyses' do
      stale_simulations.stub(:delete_all)
      stale_analyses.should_receive(:delete_all)
      stale_analyses.each do |a|
        AnalysisCleanup.should_receive(:perform_async).with(a.game_id, a.id)
      end
      finished.each do |sim|
        sim.stub(:requeue)
      end
      DailyCleanup.new.perform
    end
  end
end
