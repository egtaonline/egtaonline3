class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.integer :profile_id, null: false
      t.integer :scheduler_id, null: false
      t.integer :size, null: false
      t.string :state, null: false, default: 'pending'
      t.integer :job_id
      t.string :error_message
      t.string :qos
      t.timestamps
    end
  end
end
