class AnalysisPbsFormatter
   
   def initialize(email, day, hour, min, memory, unit)      
      hours = hour.to_i + day.to_i * 24
      @email = email
      @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',min)}:00" 
      @memory = memory + unit
   end

   def write_pbs(pbs, path)
      File.open("#{path}", 'w', 0770) do |f|
         f.write(pbs)
      end
   end
   
   def submit(pbs_path)
      proxy = Backend.connection.acquire      
       if proxy
         begin
           response = proxy.exec!("qsub -V -r n #{pbs_path}")       
             flash[:alert] = "Submission failed: #{response}" unless response =~ /\A(\d+)/
         rescue => e
             flash[:alert] = "Submission failed: #{e}"
         end
       end
   end



   def prepare_pbs(pbs_error_file, pbs_output_file, set_up_remote_command, running_script_command, clean_up_command)
      <<-DOCUMENT
#!/bin/bash
#PBS -N analysis

#PBS -A wellman_flux
#PBS -q flux
#PBS -l qos=flux
#PBS -W group_list=wellman

#PBS -l walltime=#{@walltime}
#PBS -l nodes=1:ppn=1,pmem=#{@memory}

#PBS -e #{pbs_error_file}
#PBS -o #{pbs_output_file}

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


