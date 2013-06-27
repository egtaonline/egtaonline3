require 'backend/flux/pbs_creator'

describe PbsCreator do
  let(:simulators_path){ 'fake/path' }
  let(:local_data_path){ 'fake/local/path' }
  let(:remote_data_path){ 'fake/remote/path' }
  let(:pbs_creator){ PbsCreator.new(simulators_path, local_data_path, remote_data_path) }
  let(:simulator){ double(name: 'fake', fullname: 'fake-1', email: 'fake@example.com') }
  let(:node_count){ 1 }
  let(:scheduler){ double(simulator: simulator, process_memory: 1000, time_per_observation: 300, nodes: node_count) }
  let(:simulation){ double(id: 1, size: 10, scheduler: scheduler, flux: flux_value) }

  describe '#prepare' do
    let(:top){ "#!/bin/bash\n#PBS -S /bin/sh\n" }
    let(:middle){ "#PBS -q flux\n" + "#PBS -l nodes=#{scheduler.nodes},pmem=#{scheduler.process_memory}mb,walltime=#{walltime(scheduler.time_per_observation, simulation.size)},qos=flux\n" +
                  "#PBS -N egta-#{simulator.name}\n#PBS -W umask=0007\n" +
                  "#PBS -W group_list=wellman\n#PBS -o #{remote_data_path}/#{simulation.id}/out\n" +
                  "#PBS -e #{remote_data_path}/#{simulation.id}/error\n#PBS -M #{simulator.email}\n" +
                  "umask 0007\nmkdir /tmp/${PBS_JOBID}\ncp -r #{simulators_path}/#{simulator.fullname}/#{simulator.name}/* /tmp/${PBS_JOBID}\n" +
                  "cp -r #{remote_data_path}/#{simulation.id} /tmp/${PBS_JOBID}\ncd /tmp/${PBS_JOBID}\nscript/batch #{simulation.id} #{simulation.size}" }
    let(:bottom){ "\ncp -r /tmp/${PBS_JOBID}/#{simulation.id} #{remote_data_path}\nrm -rf /tmp/${PBS_JOBID}"}

    context 'when the simulation is to be scheduled on flux' do
      let(:flux_value){ true }
      let(:response){ top + "#PBS -A wellman_flux\n" + middle + bottom }

      it 'writes out a flux wrapper to the necessary location and sets the permissions' do
        f = double("file")
        f.should_receive(:write).with(response)
        File.should_receive(:open).with("#{local_data_path}/#{simulation.id}/wrapper", 'w').and_yield(f)
        FileUtils.should_receive(:chmod_R).with(0775, "#{local_data_path}/#{simulation.id}")
        pbs_creator.prepare(simulation)
      end
    end

    context 'when the simulation is not to be scheduled on flux' do
      let(:flux_value){ false }
      let(:response){ top + "#PBS -A engin_flux\n" + middle + bottom }

      it 'writes out a flux wrapper to the necessary location and sets the permissions' do
        f = double("file")
        f.should_receive(:write).with(response)
        File.should_receive(:open).with("#{local_data_path}/#{simulation.id}/wrapper", 'w').and_yield(f)
        FileUtils.should_receive(:chmod_R).with(0775, "#{local_data_path}/#{simulation.id}")
        pbs_creator.prepare(simulation)
      end
    end

    context 'when the simulation requires multiple nodes' do
      let(:node_count){ 10 }
      let(:flux_value){ true }
      let(:response){ top + "#PBS -A wellman_flux\n" + middle + " ${PBS_NODEFILE}" + bottom }

      it 'writes out a flux wrapper to the necessary location and sets the permissions' do
        f = double("file")
        f.should_receive(:write).with(response)
        File.should_receive(:open).with("#{local_data_path}/#{simulation.id}/wrapper", 'w').and_yield(f)
        FileUtils.should_receive(:chmod_R).with(0775, "#{local_data_path}/#{simulation.id}")
        pbs_creator.prepare(simulation)
      end
    end
  end
end

def walltime(time_per, number)
  walltime_val = number*time_per
  pbs_wall_time = [ walltime_val/3600, (walltime_val/60) % 60, walltime_val % 60 ].map{ |time| "%02d" % time }.join(":")
end