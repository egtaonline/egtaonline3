class CreateLearningScripts < ActiveRecord::Migration
  def change
    create_table :learning_scripts do |t|
      t.boolean :verbose
      t.decimal :regret
      t.decimal :dist
      t.decimal :support
      t.decimal :converge
      t.integer :iters
      t.integer :points
      t.integer :analysis_id
      t.boolean :enable_dominance

      t.timestamps
    end
  end
end
