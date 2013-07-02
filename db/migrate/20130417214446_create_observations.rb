class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.integer :profile_id, :null => false
      t.json :features
      t.timestamps
    end
  end
end
