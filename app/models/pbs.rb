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
      self.scripts = pbs_file
      self.save
      #throw an error 
   end
 
   
   def prepare_pbs(set_up_remote_command, running_script_command, clean_up_command)
      pbs_error_path = File.join(@path_obj.remote_pbs_path, @path_obj.pbs_error_file)
      pbs_output_path = File.join(@path_obj.remote_pbs_path, @path_obj.pbs_output_file)
      <<-DOCUMENT
#!/bin/bash
#SBATCH --job-name=analysis-#{self.analysis_id}

#SBATCH --account=wellman
#SBATCH --partition=standard-oc

#SBATCH --time=#{@walltime}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=#{@memory}

#SBATCH --error=#{pbs_error_path}
#SBATCH --output=#{pbs_output_path}

#SBATCH --mail-user=#{@email}
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --export=All

umask 0022

#{set_up_remote_command}
#{running_script_command}
#{clean_up_command}
    DOCUMENT
  end
end
