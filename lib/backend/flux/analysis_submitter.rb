class AnalysisSubmitter
	def self.submit(pbs_path)
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
end