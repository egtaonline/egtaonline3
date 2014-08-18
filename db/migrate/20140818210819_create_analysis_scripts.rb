class CreateAnalysisScripts < ActiveRecord::Migration
  def change
    create_table :analysis_scripts do |t|
      t.boolean :verbose
      t.decimal :regret
      t.decimal :dist
      t.decimal :support
      t.decimal :converge
      t.integer :iters
      t.integer :points
      t.integer :analysis_id

      t.timestamps
    end
  end
end
