class CreateReductionScripts < ActiveRecord::Migration
  def change
    create_table :reduction_scripts do |t|
      t.text :mode
      t.json :reduced_number_hash
      t.integer :analysis_id
      t.json :output
      
      t.timestamps
    end
  end
end
