class PbsFormatter
  def initialize(path_finder)
    @path_finder = path_finder
  end

  def format(allocation, nodes, memory, walltime, simulator_tag, email, sim_id, sim_size, extra_args)
    <<-DOCUMENT
#!/bin/bash
#PBS -S /bin/sh
#PBS -A #{allocation}
#PBS -q flux
#PBS -l nodes=#{nodes},pmem=#{memory}mb,walltime=#{walltime},qos=flux
#PBS -N #{simulator_tag}
#PBS -W umask=0007
#PBS -W group_list=wellman
#PBS -o #{@path_finder.output_path}
#PBS -e #{@path_finder.error_path}
#PBS -M #{email}
umask 0007
mkdir /tmp/${PBS_JOBID}
cp -r #{@path_finder.simulator_path}/* /tmp/${PBS_JOBID}
cp -r #{@path_finder.simulation_path} /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch #{sim_id} #{sim_size}#{extra_args}
cp -r /tmp/${PBS_JOBID}/#{sim_id} #{@path_finder.data_path}
rm -rf /tmp/${PBS_JOBID}
    DOCUMENT
  end
end