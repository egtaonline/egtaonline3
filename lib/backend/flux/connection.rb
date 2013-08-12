class Connection
  def initialize(options)
    @flux_proxy = options[:proxy]
  end

  def authenticate(options)
    begin
      @flux_proxy.authenticate(options[:uniqname], options[:verification_number], options[:password])
    rescue Exception => e
      puts e.message
      false
    end
  end

  def acquire
    if @flux_proxy.authenticated?
      @flux_proxy
    else
      Backend.connected = false
      nil
    end
  end
end