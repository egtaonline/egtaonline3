class AddIndexToLearningScripts < ActiveRecord::Migration
  def change
    add_index :learning_scripts, :analysis_id
  end
end
