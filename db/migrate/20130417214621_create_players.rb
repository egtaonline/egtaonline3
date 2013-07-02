class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.float :payoff, :null => false
      t.json :features
      t.integer :observation_id, :null => false
      t.integer :symmetry_group_id, :null => false

      t.timestamps
    end
  end
end
