class MoveGamesFromMongo < ActiveRecord::Migration
  def up
    unless Rails.env == 'test'
      session = Moped::Session.new(['127.0.0.1:27017'])
      session.use :egt_web_interface_production
      session.login(ENV['mongo_username'], ENV['mongo_password'])
      remove_duplicates(session)
      session[:games].find.each do |game|
        puts game['name'].inspect
        simulator_instance_id = get_simulator_instance_id(game, session)
        puts simulator_instance_id
        new_game = Game.create!(name: game['name'], size: game['size'],
          simulator_instance_id: simulator_instance_id)
        game['roles'].each do |role|
          new_game.roles.create!(name: role['name'],
            strategies: role['strategies'],
            count: role['count'], reduced_count: role['count'])
        end
      end
    end
  end

  def down
    unless Rails.env == 'test'
      Game.destroy_all
    end
  end

  private

  def get_simulator_instance_id(game, session)
    configuration_string = game['configuration'].collect { |key,value| "\"#{key}\" => \"#{value}\"" }.join(', ')
    simulator_id = session[:simulators].find(_id: BSON::ObjectId.from_string(game[:simulator_id])).first['new_id']
    puts simulator_id
    simulator_instance = SimulatorInstance.where('simulator_id = ? AND configuration @> (?)', simulator_id, configuration_string).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id, configuration: game['configuration'])
    simulator_instance.id
  end

  def remove_duplicates(session)
    session[:games].find.distinct(:name).each do |name|
      count = 0
      session[:games].find(name: name).each do |game|
        unless count == 0
          session[:games].find(_id: game[:_id]).update('$set' =>
            { name: "#{name}#{count}" })
        end
        count += 1
      end
    end
  end
end
