class MovingSchedulersFromMongo < ActiveRecord::Migration
  def up
    unless Rails.env == "test"
      session = Moped::Session.new(["127.0.0.1:27017"])
      session.use :egt_web_interface_production
      session.login(ENV['mongo_username'], ENV['mongo_password'])
      session[:schedulers].find.each do |scheduler|
        begin
          simulator_instance_id = get_simulator_instance_id(scheduler, session)
        rescue Exception => e
          puts 'stupid fail'
        end
        if simulator_instance_id
          args = { name: scheduler["name"], active: scheduler["active"],
                   process_memory: scheduler["process_memory"], time_per_observation: scheduler["time_per_sample"],
                   observations_per_simulation: scheduler["samples_per_simulation"],
                   default_observation_requirement: scheduler["default_samples"], nodes: scheduler["nodes"],
                   size: scheduler["size"], simulator_instance_id: simulator_instance_id }
          case scheduler["_type"]
          when "GameScheduler"
            new_scheduler = GameScheduler.create!(args)
            add_roles(new_scheduler, scheduler)
          when "DeviationScheduler"
            new_scheduler = DeviationScheduler.create!(args)
            add_roles_with_deviators(new_scheduler, scheduler)
          when "DprGameScheduler"
            new_scheduler = DprScheduler.create!(args)
            add_roles(new_scheduler, scheduler)
          when "DprDeviationScheduler"
            new_scheduler = DprDeviationScheduler.create!(args)
            add_roles_with_deviators(new_scheduler, scheduler)
          when "HierarchicalScheduler"
            new_scheduler = HierarchicalScheduler.create!(args)
            add_roles(new_scheduler, scheduler)
          when "HierarchicalDeviationScheduler"
            new_scheduler = HierarchicalDeviationScheduler.create!(args)
            add_roles_with_deviators(new_scheduler, scheduler)
          when "GenericScheduler"
            new_scheduler = GenericScheduler.create!(args)
            add_roles(new_scheduler, scheduler)
            add_scheduling_requirements(new_scheduler, scheduler, session)
          end
        end
      end
    end
  end

  def down
    unless Rails.env == "test"
      Scheduler.destroy_all
    end
  end

  private

  def get_simulator_instance_id(scheduler, session)
    configuration_string = scheduler["configuration"].collect{ |key,value| "\"#{key}\" => \"#{value}\"" }.join(", ")
    simulator_id = session[:simulators].find(_id: BSON::ObjectId.from_string(scheduler[:simulator_id])).first["new_id"]
    simulator_instance = SimulatorInstance.where("simulator_id = ? AND configuration @> (?)", simulator_id, configuration_string).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id, configuration: scheduler["configuration"])
    simulator_instance.id
  end

  def add_roles(new_scheduler, scheduler)
    scheduler["roles"].each do |role|
      if new_scheduler.simulator.role_configuration[role['name']]
        new_scheduler.roles.create(name: role['name'], count: role['count'], reduced_count: role['reduced_count'],
          strategies: (new_scheduler.simulator.role_configuration[role['name']] | role['strategies']).uniq.sort, deviating_strategies: [])
      end
    end
  end

  def add_roles_with_deviators(new_scheduler, scheduler)
    scheduler["roles"].each do |role|
      if new_scheduler.simulator.role_configuration[role['name']]
        dev_role = scheduler["deviating_roles"].find{ |drole| drole['name'] == role['name']}
        new_scheduler.roles.create(name: role['name'], count: role['count'], reduced_count: role['reduced_count'],
          strategies: (new_scheduler.simulator.role_configuration[role['name']] | role['strategies']).uniq.sort,
          deviating_strategies: (new_scheduler.simulator.role_configuration[role['name']] | dev_role['strategies']).uniq.sort)
      end
    end
  end

  def add_scheduling_requirements(new_scheduler, scheduler, session)
    scheduler['sample_hash'].each do |pid, count|
      begin
        profile = Profile.find(session[:profiles].find(_id: BSON::ObjectId.from_string(pid)).first["new_id"])
      rescue Exception => e
        puts "Missing #{pid}"
      end
      if profile && count != nil && count != 0
        profile.scheduling_requirements.create!(scheduler_id: new_scheduler.id, count: count)
      end
    end
  end
end
