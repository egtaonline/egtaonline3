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

  def authenticated?
    @flux_proxy.authenticated?
  end

  def acquire
    if @flux_proxy.authenticated?
      @flux_proxy
    else
      nil
    end
  end
end