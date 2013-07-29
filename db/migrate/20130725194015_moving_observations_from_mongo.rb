class MovingObservationsFromMongo < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def up
    unless Rails.env == "test"
      session = Moped::Session.new(["127.0.0.1:27017"])
      session.use :egt_web_interface_production
      counter = 0
      total_count = session[:profiles].find(sample_count: { "$gt" => 0 }).count
      puts total_count
      while counter < total_count
        ActiveRecord::Base.transaction do
          query(session[:profiles], counter).each do |profile|
            if profile["new_id"]
              profile["observations"].each do |obs|
                observation = Observation.create!(profile_id: profile["new_id"],
                  features: obs["features"])
                obs["symmetry_groups"].each do |sym|
                  sid = SymmetryGroup.find_by(profile_id: profile["new_id"],
                    role: sym["role"], strategy: sym["strategy"]).id
                  sym["players"].each do |player|
                    observation.players.create!(symmetry_group_id: sid,
                      payoff: player["payoff"], features: player["features"])
                  end
                end
              end
            end
          end
        end
        counter += 50
        puts counter
      end
    end
  end

  def down
    unless Rails.env == "test"
      Observation.destroy_all
    end
  end

  private

  def query(collection, counter)
    collection.find(sample_count: {"$gt" => 0}).limit(50).skip(counter).select(
      "new_id" => 1, "observations.features" => 1,
      "observations.symmetry_groups.role" => 1,
      "observations.symmetry_groups.strategy" => 1,
      "observations.symmetry_groups.players.payoff" => 1,
      "observations.symmetry_groups.players.features" => 1)
  end
end
