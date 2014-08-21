class CreatePbs < ActiveRecord::Migration
  def change
    create_table :pbs do |t|
      t.integer :day
      t.integer :hour
      t.integer :minute
      t.integer :memory
      t.text :memory_unit
      t.integer :analysis_id
      t.text :scripts
      
      t.timestamps
    end
  end
end
