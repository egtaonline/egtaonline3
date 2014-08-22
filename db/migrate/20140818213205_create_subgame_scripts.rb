class CreateSubgameScripts < ActiveRecord::Migration
  def change
    create_table :subgame_scripts do |t|
      t.json :subgame
      t.json :reduced_number_hash
      t.integer :analysis_id
      t.json :output
      
      t.timestamps
    end
  end
end
