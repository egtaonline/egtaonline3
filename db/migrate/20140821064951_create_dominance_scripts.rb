class CreateDominanceScripts < ActiveRecord::Migration
  def change
    create_table :dominance_scripts do |t|
      t.json :output
      t.integer :analysis_id

      t.timestamps
    end
  end
end
