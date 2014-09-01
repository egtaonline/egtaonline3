class Pbs < ActiveRecord::Base
	belongs_to :analysis
	after_initialize :prepare

   def prepare
      hours = self.hour.to_i + self.day.to_i * 24
      @email = self.user_email
      @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',self.minute)}:00" 
      @memory = self.memory.to_s + self.memory_unit
	    @path_obj = AnalysisPathFinder.new(Analysis.find(self.analysis_id).game_id.to_s, self.analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
   end

   def format(set_up_remote_command, running_script_command, clean_up_command)
      pbs_file = prepare_pbs(set_up_remote_command, running_script_command, clean_up_command)     
      @pbs.scripts = pbs_file
      @pbs.save
      #throw an error 
   end
 
   
   def prepare_pbs(set_up_remote_command, running_script_command, clean_up_command)
      pbs_error_path = File.join(@path_finder.remote_pbs_path, @path_finder.pbs_error_file)
      pbs_output_path = File.join(@path_finder.remote_pbs_path, @path_finder.pbs_output_file)
      <<-DOCUMENT
#!/bin/bash
#PBS -N analysis-#{self.analysis_id}

#PBS -A wellman_flux
#PBS -q flux
#PBS -l qos=flux
#PBS -W group_list=wellman

#PBS -l walltime=#{@walltime}
#PBS -l nodes=1:ppn=1,pmem=#{@memory}

#PBS -e #{pbs_error_path}
#PBS -o #{pbs_output_path}

#PBS -M #{@email}
#PBS -m abe
#PBS -V
#PBS -W umask=0022

umask 0022

#{set_up_remote_command}
#{running_script_command}
#{clean_up_command}
    DOCUMENT
  end
end
