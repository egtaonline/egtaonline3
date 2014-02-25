class PbsFormatter
  def initialize(path_finder)
    @path_finder = path_finder
  end

  def format(allocation, nodes, memory, walltime, simulator_tag, email, sim_id, sim_size, extra_args)
    "#!/bin/bash\n" +
    "#PBS -S /bin/sh\n" +
    "#PBS -A #{allocation}\n" +
    "#PBS -q flux\n" +
    "#PBS -l nodes=#{nodes},pmem=#{memory}mb,walltime=#{walltime},qos=flux\n" +
    "#PBS -N #{simulator_tag}\n" +
    "#PBS -W umask=0007\n" +
    "#PBS -W group_list=wellman\n" +
    "#PBS -o #{@path_finder.output_path}\n" +
    "#PBS -e #{@path_finder.error_path}\n" +
    "#PBS -M #{email}\n" +
    "umask 0007\n" +
    "mkdir /tmp/${PBS_JOBID}\n" +
    "cp -r #{@path_finder.simulator_path}/* /tmp/${PBS_JOBID}\n" +
    "cp -r #{@path_finder.simulation_path} /tmp/${PBS_JOBID}\n" +
    "cd /tmp/${PBS_JOBID}\n" +
    "script/batch #{sim_id} #{sim_size}#{extra_args}\n" +
    "cp -r /tmp/${PBS_JOBID}/#{sim_id} #{@path_finder.data_path}\n" +
    "rm -rf /tmp/${PBS_JOBID}"
  end
end