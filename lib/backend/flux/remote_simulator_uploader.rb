class RemoteSimulatorUploader
  def initialize(simulators_path)
    @simulators_path = simulators_path
  end

  def upload(connection, simulator)
    proxy = connection.acquire
    if proxy
      proxy.upload!(simulator.source.path, "#{@simulators_path}/#{simulator.name}.zip")
      outcome = proxy.exec!("[ -f \"#{@simulators_path}/#{simulator.name}.zip\" ] && echo \"exists\" || echo \"not exists\"")
      if outcome =~ /^exists/
        proxy.exec!("cd #{@simulators_path} && unzip -uqq #{simulator.name}.zip -d #{simulator.fullname} && chmod -R ug+rwx #{simulator.fullname}")
      else
        raise 'Upload failed.'
      end
    else
      raise "Connection broken."
    end
  end
end