class CreateSubgameScripts < ActiveRecord::Migration
  def change
    create_table :subgame_scripts do |t|
      t.json :subgame
      t.integer :analysis_id
      
      
      t.timestamps
    end
  end
end
