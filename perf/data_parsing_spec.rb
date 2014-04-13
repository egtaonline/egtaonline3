require 'spec_helper'
require 'jruby/profiler'

describe 'parsing data' do
  it 'does reasonable things' do
    profile = create(
      :profile, assignment: 'BACKGROUND: 22 ZIR:bidRangeMin_0_bid' \
                      'RangeMax_10000, 33 ZIR:bidRangeMin_0_bid' \
                      'RangeMax_2500, 11 ZIR:bidRangeMin_50000_bid' \
                      'RangeMax_100000; MARKETMAKER: 1 MAMM:numRungs' \
                      '_200_rungSize_100_numHistorical_5_initLadder' \
                      'Mean_100000_initLadderRange_5000')
    simulation = create(:simulation, profile: profile, id: 172_808)
    location = "#{Rails.root}/perf/172808"
    profile_data = JRuby::Profiler.profile do
      DataParser.new.perform(simulation.id, location)
    end
    JRuby::Profiler::FlatProfilePrinter.new(profile_data).printProfile(STDOUT)
  end
end
