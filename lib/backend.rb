Dir[File.dirname(__FILE__)+'/backend/*.rb'].each{ |file| require file }

module Backend
  def self.prepare_simulator(simulator)
  end
end