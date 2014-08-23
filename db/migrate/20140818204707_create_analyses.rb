class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.integer :game_id
      t.text :status
      t.integer :job_id
      t.text :error_message
      t.text :output
      t.json :subgame

      t.timestamps
    end
  end
end
