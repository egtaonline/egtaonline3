class AnalysisUpdatter
	def initialize(analysis)
		@analysis = analysis
		@path_finder = AnalysisPathFinder.new(analysis.game_id.to_s, analysis.id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
	end


  def update_analysis(analyses)
    proxy = connection.acquire
    if proxy
      output = proxy.exec!('qstat -a | grep analysis-')
      status_hash = parse_to_hash(output)
      if status_hash
        analyses.each do |analysis|
        AnalysisStatusResolver.new.act_on_status(
            status_hash[simulation.job_id.to_s], simulation)
        end
      end
    end
  end

  private

  def parse_to_hash(output)
    unless output =~ /^failure/
      parsed_output = {}
      if output && output != ''
        output.split("\n").each do |line|
          parsed_output[line.split('.').first] = line.split(/\s+/)[9]
        end
      end
      parsed_output
    end
  end

end