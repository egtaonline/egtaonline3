class MoveSimulatorsFromMongo < ActiveRecord::Migration
  def up
    unless Rails.env == 'test'
      Simulator.skip_callback(:validation, :before, :setup_simulator)
      session = Moped::Session.new(['127.0.0.1:27017'])
      session.use :egt_web_interface_production
      session.login(ENV['mongo_username'], ENV['mongo_password'])
      session[:simulators].find(simulator_source: nil).each do |sim|
        session[:simulators].find(_id: sim[:_id]).update('$set' => {
          simulator_source: sim[:simulator_source_filename] })
      end
      session[:simulators].find(new_id: { '$exists' => false }).each do |sim|
        role_configuration = {}
        sim['roles'] ||= []
        sim['roles'].each do |role|
          role_configuration[role['name']] = role['strategies']
        end
        begin
          simulator = Simulator.create!(name: sim['name'],
            version: sim['version'],
            email: sim['email'],
            source: File.new(sim['simulator_source'], 'w'),
            configuration: sim['configuration'],
            role_configuration: role_configuration)
          session[:simulators].find(_id: sim[:_id]).update('$set' => {
            new_id: simulator.id })
        rescue Exception
          puts sim['name']
        end
      end
    end
  end

  def down
    unless Rails.env == 'test'
      Simulator.destroy_all
      session = Moped::Session.new(['127.0.0.1:27017'])
      session.use :egt_web_interface_production
      session[:simulators].find.update_all('$unset' => { 'new_id' => '' })
    end
  end
end
