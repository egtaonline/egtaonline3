class AnalysisPbsFormatter
   
   def initialize(pbs, path_obj)
      @pbs = pbs      
      hours = pbs.hour.to_i + pbs.day.to_i * 24
      @email = pbs.user_email
      @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',pbs.minute)}:00" 
      @memory = pbs.memory.to_s + pbs.memory_unit
      @path_finder = path_obj

   end

   def write_pbs(game_id, set_up_remote_command, running_script_command, clean_up_command)
      pbs_file = prepare_pbs(game_id, set_up_remote_command, running_script_command, clean_up_command)
      File.open("#{File.join(@path_finder.local_data_path, @path_finder.pbs_file_name)}", 'w', 0770) do |f|
         f.write(pbs_file)
      end
      @pbs.scripts = pbs_file
      @pbs.save
      #throw an error 
   end
   
   # def submit(pbs_path)
   #      # proxy = nil
   #    proxy = Backend.connection.acquire      
       
   #     if proxy
   #       begin
   #         response = proxy.exec!("qsub -V -r n #{pbs_path}")       
   #         return response
            
   #       rescue => e
   #          return e.message
   #       end
   #     else
   #        return "Lost connection to flux"
   #     end
   # end

   private 
   
   def prepare_pbs(game_id, set_up_remote_command, running_script_command, clean_up_command)
    pbs_error_path = File.join(@path_finder.remote_data_path, @path_finder.pbs_error_file)
    pbs_output_path = File.join(@path_finder.remote_data_path, @path_finder.pbs_output_file)
      <<-DOCUMENT
#!/bin/bash
#PBS -N analysis-#{game_id}

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


