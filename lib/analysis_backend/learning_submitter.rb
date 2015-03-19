class LearningSubmitter
	def initialize(game_id, current_time, day, hour, min, memory, unit, cv, regret, dist, converge, iters, samples, email)

    	@game_id = game_id
        @current_time = current_time
        hours = hour.to_i + day.to_i * 24

        @walltime = "#{sprintf('%02d',hours)}:#{sprintf('%02d',min)}:00" 

        @memory = memory.to_s + unit
        @unit = unit
        @email = email

        @cv = cv
        @regret = regret
        @dist = dist
        @converge = converge

        @iters = iters
        @samples = samples
    	  
        @local_path = "/mnt/nfs/home/egtaonline"
        # @local_path = "#{Rails.root}"
        @local_data_path = "#{@local_path}/learning/#{@game_id}"
        @remote_path = "/nfs/wellman_ls/egtaonline/learning/#{@game_id}"
        @document = create_pbs
    end

    def submit
        File.open("#{@local_data_path}/wrapper", 'w', 0770) do |f|
          f.write(@document)
        end
    
        proxy = Backend.connection.acquire
        # proxy = nil
        if proxy
          begin
            response = proxy.exec!("qsub -V -r n #{@remote_path}/wrapper")
            flash[:alert] = "Submission failed: #{response}" unless response =~ /\A(\d+)/
            rescue => e
              flash[:alert] = "Submission failed: #{e}"
          end
        end
    end
  
  def create_pbs
<<-DOCUMENT
#!/bin/bash
#PBS -N analysis
#PBS -A wellman_flux
#PBS -q flux
#PBS -l qos=flux
#PBS -W group_list=wellman
#PBS -l walltime=#{@walltime}
#PBS -l nodes=1:ppn=1,pmem=#{@memory}
#PBS -M #{@email}
#PBS -m abe
#PBS -V
#PBS -W umask=0007
umask 0007
module load python/2.7.5
module load lsa anaconda2
mkdir /tmp/${PBS_JOBID}
cp -r #{@remote_path}/in/game#{@game_id}-learning-#{@current_time}.json /tmp/${PBS_JOBID}
cp -r /nfs/wellman_ls/test/test.py /tmp/${PBS_JOBID}
cd /tmp/${PBS_JOBID}
export PYTHONPATH=$PYTHONPATH:/nfs/wellman_ls/GameAnalysis

python test.py  game#{@game_id}-learning-#{@current_time}.json -r #{@regret} -d #{@dist} -c #{@converge} -i #{@iters} -s 1e-3 -sp #{@samples} > game#{@game_id}-learning-#{@current_time}.out 

cp -r /tmp/${PBS_JOBID}/#{@game_id}-analysis-#{@current_time}.out #{@remote_path}/out
rm -rf /tmp/${PBS_JOBID}
DOCUMENT
  end

end