class AnalysisPbsFormatter
   
   def initialize(pbs, path_obj)
      @pbs = pbs      
      hours = pbs.hour.to_i + pbs.day.to_i * 24
      @email = pbs.user_email
      @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',pbs.minute)}:00" 
      @memory = pbs.memory.to_s + pbs.memory_unit
      @path_finder = path_obj

   end

   def format(game_id, set_up_remote_command, running_script_command, clean_up_command)
      pbs_file = prepare_pbs(game_id, set_up_remote_command, running_script_command, clean_up_command)
     
      @pbs.scripts = pbs_file
      @pbs.save
      #throw an error 
   end
 
   
   def prepare_pbs(game_id, set_up_remote_command, running_script_command, clean_up_command)
    pbs_error_path = File.join(@path_finder.remote_pbs_path, @path_finder.pbs_error_file)
    pbs_output_path = File.join(@path_finder.remote_pbs_path, @path_finder.pbs_output_file)
      <<-DOCUMENT
#!/bin/bash
#SBATCH --job-name=analysis-#{game_id}

#SBATCH --account=wellman
#SBATCH --partition=standard-oc
#SBATCH --time=#{@walltime}
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=#{@memory}
#SBATCH --ntasks-per-node=1
#SBATCH --output=#{pbs_output_path}
#SBATCH --error=#{pbs_error_path}
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


