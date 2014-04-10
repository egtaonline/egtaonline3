require 'backend/flux/pbs_clock_time'

describe PbsClockTime do
  describe '.walltime' do
    it 'converts seconds into the PBS time format' do
      PbsClockTime.walltime(4000).should == '01:06:40'
    end
  end
end
