require 'backend/flux/pbs_formatter'

describe PbsFormatter do
  describe '.create_wrapper' do
    let(:path_finder) do
      double(simulator_path: 'simulator/path', simulation_path: 'simulation/path',
             output_path: 'output/path', error_path: 'error/path', data_path: 'data/path')
    end
    let(:allocation){ 'flux' }
    let(:nodes){ 1 }
    let(:memory){ 1000 }
    let(:walltime){ '01:06:40' }
    let(:simulation_tag){ 'egta-sim' }
    let(:email){ 'fake@email.com' }
    let(:sim_id){ 1 }
    let(:sim_size){ 10 }
    let(:extra_args) { "" }
    subject{ PbsFormatter.new(path_finder) }
    it 'formats appropriately' do
      subject.format(allocation, nodes, memory, walltime, simulation_tag, 
                     email, sim_id, sim_size, extra_args).should ==
                "#!/bin/bash\n" +
                "#PBS -S /bin/sh\n" +
                "#PBS -A #{allocation}\n" +
                "#PBS -q flux\n" +
                "#PBS -l nodes=#{nodes},pmem=#{memory}mb,walltime=#{walltime},qos=flux\n" +
                "#PBS -N #{simulation_tag}\n" +
                "#PBS -W umask=0007\n" +
                "#PBS -W group_list=wellman\n" +
                "#PBS -o #{path_finder.output_path}\n" +
                "#PBS -e #{path_finder.error_path}\n" +
                "#PBS -M #{email}\n" +
                "umask 0007\n" +
                "mkdir /tmp/${PBS_JOBID}\n" +
                "cp -r #{path_finder.simulator_path}/* /tmp/${PBS_JOBID}\n" +
                "cp -r #{path_finder.simulation_path} /tmp/${PBS_JOBID}\n" +
                "cd /tmp/${PBS_JOBID}\n" +
                "script/batch #{sim_id} #{sim_size}#{extra_args}\n" +
                "cp -r /tmp/${PBS_JOBID}/#{sim_id} #{path_finder.data_path}\n" +
                "rm -rf /tmp/${PBS_JOBID}\n"
    end
  end
end