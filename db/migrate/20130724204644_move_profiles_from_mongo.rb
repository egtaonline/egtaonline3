class MoveProfilesFromMongo < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def up
    unless Rails.env == "test"
      session = Moped::Session.new(["127.0.0.1:27017"])
      session.use :egt_web_interface_production
      session.login(ENV['mongo_username'], ENV['mongo_password'])
      invalid_count = 0
      counter = 0
      total_count = session[:profiles].find.count
      while counter < total_count
        ActiveRecord::Base.transaction do
          session[:profiles].find.limit(1000).skip(counter).select(
            "simulator_id" => 1, "configuration" => 1,
            "assignment" => 1).each do |profile|
            begin
              simulator_instance_id = get_simulator_instance_id(profile, session)
              p = Profile.create(simulator_instance_id: simulator_instance_id,
                assignment: profile["assignment"])
              if p.valid?
                session[:profiles].find(_id: profile[:_id]).update("$set" => {
                  new_id: p.id})
              else
                invalid_count += 1
              end
            rescue Exception => e
              invalid_count += 1
            end
          end
        end
        counter += 1000
        puts counter
      end
      puts invalid_count
    end
  end

  def down
    unless Rails.env == "test"
      Profile.destroy_all
      session = Moped::Session.new(["127.0.0.1:27017"])
      session.use :egt_web_interface_production
      session[:profiles].find.update_all("$unset" => { "new_id" => "" })
    end
  end

  private

  def get_simulator_instance_id(profile, session)
    configuration_string = profile["configuration"].collect do |key,value|
      "\"#{key}\" => \"#{value}\""
    end.join(", ")
    simulator_id = session[:simulators].find(_id: BSON::ObjectId.from_string(profile[:simulator_id])).first["new_id"]
    simulator_instance = SimulatorInstance.where("
      simulator_id = ? AND configuration @> (?)", simulator_id,
      configuration_string).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id,
      configuration: profile["configuration"])
    simulator_instance.id
  end
end
