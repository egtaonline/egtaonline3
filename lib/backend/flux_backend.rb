class FluxBackend
  attr_accessor :flux_active_limit, :simulations_path, :flux_simulations_path, :simulators_path

  def setup_connections
    @flux_proxy = DRbObject.new_with_uri('druby://localhost:30000')
  end

  def authenticate(options)
    begin
      @flux_proxy.authenticate(options[:uniqname], options[:verification_number], options[:password])
    rescue Exception => e
      puts e.message
      return false
    end
  end
end