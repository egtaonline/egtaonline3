class AnalysisUpdatter
  def initialize

  end


  def update_analysis(analyses)
    proxy = Backend.connection.acquire
    if proxy
      output = proxy.exec!('squeue -a | grep analysis-')
      status_hash = parse_to_hash(output)
      if status_hash
        analyses.each do |analysis|
        Rails.logger.info "Status Hash:#{status_hash[analysis.job_id.to_s]}"
        AnalysisStatusResolver.new(analysis).act_on_status(
            status_hash[analysis.job_id.to_s])
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
          parsed_output[line.split(' ').first] = line.split(' ')[5]
        end
      end
      parsed_output
    end
  end

end
