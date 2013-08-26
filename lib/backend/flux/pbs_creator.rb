class PbsCreator
  def initialize(simulators_path, local_data_path, remote_data_path)
    @simulators_path, @local_data_path, @remote_data_path = simulators_path, local_data_path, remote_data_path
  end

  def prepare(simulation)
    scheduler = simulation.scheduler
    allocation = simulation.qos == 'flux' ? 'wellman_flux' : 'engin_flux'
    queue =  'flux'
    simulator = simulation.scheduler.simulator
    root_path = "#{@simulators_path}/#{simulator.fullname}/#{simulator.name}"
    extra_args = scheduler.nodes > 1 ? " ${PBS_NODEFILE}" : ""
    walltime = simulation.size*scheduler.time_per_observation
    pbs_wall_time = [ walltime/3600, (walltime/60) % 60, walltime % 60 ].map{ |time| "%02d" % time }.join(":")
    document = "#!/bin/bash\n" +
               "#PBS -S /bin/sh\n" +
               "#PBS -A #{allocation}\n" +
               "#PBS -q #{queue}\n" +
               "#PBS -l nodes=#{scheduler.nodes},pmem=#{scheduler.process_memory}mb,walltime=#{pbs_wall_time},qos=#{queue}\n" +
               "#PBS -N egta-#{simulator.name.downcase.gsub(' ', '_')}\n" +
               "#PBS -W umask=0007\n" +
               "#PBS -W group_list=wellman\n" +
               "#PBS -o #{@remote_data_path}/#{simulation.id}/out\n" +
               "#PBS -e #{@remote_data_path}/#{simulation.id}/error\n" +
               "#PBS -M #{simulator.email}\n" +
               "umask 0007\n" +
               "mkdir /tmp/${PBS_JOBID}\n" +
               "cp -r #{root_path}/* /tmp/${PBS_JOBID}\n" +
               "cp -r #{@remote_data_path}/#{simulation.id} /tmp/${PBS_JOBID}\n" +
               "cd /tmp/${PBS_JOBID}\n" +
               "script/batch #{simulation.id} #{simulation.size}#{extra_args}\n" +
               "cp -r /tmp/${PBS_JOBID}/#{simulation.id} #{@remote_data_path}\n" +
               "rm -rf /tmp/${PBS_JOBID}"

    File.open("#{@local_data_path}/#{simulation.id}/wrapper", 'w'){ |f| f.write(document) }
    FileUtils.chmod_R(0775, "#{@local_data_path}/#{simulation.id}")
  end
end