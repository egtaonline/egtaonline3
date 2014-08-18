class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.integer :game_id
      t.text :status
      t.integer :job_id
      t.text :output
      t.text :error_message
      t.integer :pbs_id
      t.integer :analysis_script_id
      t.integer :reduction_script_id
      t.integer :subgame_script_id

      t.timestamps
    end
  end
end
