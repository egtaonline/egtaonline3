class CreateReductionScripts < ActiveRecord::Migration
  def change
    create_table :reduction_scripts do |t|
      t.text :mode
      t.text :reduced_number
      t.integer :analysis_id

      t.timestamps
    end
  end
end
