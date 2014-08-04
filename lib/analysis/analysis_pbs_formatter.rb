class AnalysisPbsFormatter
   
   def initialize(path_finder,running_script_command,email, walltime)
      @walltime = walltime
      @email = email
      @running_script_command = running_script_command
      @path_finder = path_finder      
   end

   def write_pbs
      File.open("#{File.join(@path_finder.local_pbs_path,@path_finder.pbs_file_name)}", 'w', 0770) do |f|
         f.write(prepare_pbs)
      end
   end
    
   private 

   def prepare_pbs
      <<-DOCUMENT
#!/bin/bash
#PBS -N analysis

#PBS -A wellman_flux
#PBS -q flux
#PBS -l qos=flux
#PBS -W group_list=wellman

#PBS -l walltime=#{@walltime}
#PBS -l nodes=1:ppn=1,pmem=4000mb

#PBS -M #{@email}
#PBS -m abe
#PBS -V
#PBS -W umask=0007

umask 0007

module load python/2.7.5

mkdir /tmp/${PBS_JOBID}
cp -r #{File.join(@path_finder.remote_input_path, @path_finder.input_file_name)} /tmp/${PBS_JOBID}
      
cp -r #{@path_finder.reduction_script_path} /tmp/${PBS_JOBID}
cp -r #{@path_finder.analysis_script_path} /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}

export PYTHONPATH=$PYTHONPATH:#{@path_finder.scripts_path }    
      
#{@running_script_command}

cp -r /tmp/${PBS_JOBID}/#{@path_finder.output_file_name} #{@path_finder.remote_output_path}
rm -rf /tmp/${PBS_JOBID}
   DOCUMENT
    end


end 


