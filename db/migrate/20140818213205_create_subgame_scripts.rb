class CreateSubgameScripts < ActiveRecord::Migration
  def change
    create_table :subgame_scripts do |t|
      t.text :subgame
      t.text :reduced_number
      t.integer :analysis_id

      t.timestamps
    end
  end
end
