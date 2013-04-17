class CreateGameProfileJoinTable < ActiveRecord::Migration
  def change
    create_table :games_profiles, :id => false do |t|
      t.integer :profile_id, :null => false
      t.integer :game_id, :null => false
    end
  end
end
