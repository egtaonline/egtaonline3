class FixSchedulers < ActiveRecord::Migration
  def up
    unless Rails.env == 'test'
      session = Moped::Session.new(['127.0.0.1:27017'])
      session.use :egt_web_interface_production
      session.login(ENV['mongo_username'], ENV['mongo_password'])
      session[:schedulers].find.each do |scheduler|
        case scheduler['_type']
        when 'GameScheduler'
          new_scheduler = GameScheduler.find_by(name: scheduler['name'])
          fix_roles(new_scheduler, scheduler)
        when 'DeviationScheduler'
          new_scheduler = DeviationScheduler.find_by(name: scheduler['name'])
          fix_roles_with_deviators(new_scheduler, scheduler)
        when 'DprGameScheduler'
          new_scheduler = DprScheduler.find_by(name: scheduler['name'])
          fix_roles(new_scheduler, scheduler)
        when 'DprDeviationScheduler'
          new_scheduler = DprDeviationScheduler.find_by(name: scheduler['name'])
          fix_roles_with_deviators(new_scheduler, scheduler)
        when 'HierarchicalScheduler'
          new_scheduler = HierarchicalScheduler.find_by(name: scheduler['name'])
          fix_roles(new_scheduler, scheduler)
        when 'HierarchicalDeviationScheduler'
          new_scheduler = HierarchicalDeviationScheduler.find_by(name: scheduler['name'])
          fix_roles_with_deviators(new_scheduler, scheduler)
        when 'GenericScheduler'
          new_scheduler = GenericScheduler.find_by(name: scheduler['name'])
          new_scheduler.roles.each do |role|
            role.update_attributes(strategies: [], deviating_strategies: [])
          end
        end
      end
    end
  end

  def down
  end

  private

  def fix_roles(new_scheduler, scheduler)
    scheduler['roles'].each do |role|
      new_role = new_scheduler.roles.find_by(name: role['name'])
      role['strategies'] ||= []
      new_role.strategies = role['strategies']
      new_role.save!
    end
  end

  def fix_roles_with_deviators(new_scheduler, scheduler)
    scheduler['roles'].each do |role|
      dev_role = scheduler['deviating_roles'].find { |drole| drole['name'] == role['name'] }
      new_role = new_scheduler.roles.find_by(name: role['name'])
      role['strategies'] ||= []
      dev_role['strategies'] ||= []
      new_role.strategies = role['strategies']
      new_role.deviating_strategies = dev_role['strategies']
      new_role.save!
    end
  end
end