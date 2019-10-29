class PbsFormatter
  def initialize(path_finder, scheduler, simulation, simulator, walltime)
    @path_finder = path_finder
    @nodes = scheduler.nodes
    @memory = scheduler.process_memory
    @sim_id = simulation.id
    @sim_size = simulation.size
    @extra_args = scheduler.nodes > 1 ? ' ${PBS_NODEFILE}' : ''
    @allocation = simulation.qos == 'flux' ? 'wellman' : 'engin'
    @simulator_tag = "egta-#{simulator.name.downcase.gsub(' ', '_')}"
    @email = simulator.email
    @walltime = walltime
  end

  def format
    <<-DOCUMENT
#!/bin/bash
#SBATCH --account=#{@allocation}
#SBATCH --partition=standard-oc
#SBATCH --nodes=#{@nodes}
#SBATCH --mem-per-cpu=#{@memory}m
#SBATCH --time=#{@walltime}
#SBATCH --job-name=#{@simulator_tag}
#SBATCH --output=#{@path_finder.output_path}
#SBATCH --error=#{@path_finder.error_path}
#SBATCH --mail-user=#{@email}
#SBATCH --mail-type=BEGIN,END
umask 0022
mkdir /tmp/${SLURM_JOB_ID}
cp -r #{@path_finder.simulator_path}/* /tmp/${SLURM_JOB_ID}
cp -r #{@path_finder.simulation_path} /tmp/${SLURM_JOB_ID}
cd /tmp/${SLURM_JOB_ID}
script/batch #{@sim_id} #{@sim_size}#{@extra_args}
cp -r /tmp/${SLURM_JOB_ID}/#{@sim_id} #{@path_finder.data_path}
rm -rf /tmp/${SLURM_JOB_ID}
    DOCUMENT
  end
=begin  
  def format
    <<-DOCUMENT
#!/bin/bash
#PBS -S /bin/sh
#PBS -A #{@allocation}
#PBS -q flux-oncampus
#PBS -l nodes=#{@nodes},pmem=#{@memory}mb,walltime=#{@walltime},qos=flux
#PBS -N #{@simulator_tag}
#PBS -W umask=0022
#PBS -W group_list=wellman
#PBS -o #{@path_finder.output_path}
#PBS -e #{@path_finder.error_path}
#PBS -M #{@email}
umask 0022
mkdir /tmp/${PBS_JOBID}
cp -r #{@path_finder.simulator_path}/* /tmp/${PBS_JOBID}
cp -r #{@path_finder.simulation_path} /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
script/batch #{@sim_id} #{@sim_size}#{@extra_args}
cp -r /tmp/${PBS_JOBID}/#{@sim_id} #{@path_finder.data_path}
rm -rf /tmp/${PBS_JOBID}
    DOCUMENT
  end
=end
end
