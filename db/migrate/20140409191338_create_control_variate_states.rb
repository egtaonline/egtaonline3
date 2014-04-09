class CreateControlVariateStates < ActiveRecord::Migration
  def up
    create_table :control_variate_states do |t|
      t.integer :simulator_instance_id, uniq: true
      t.string :state, default: 'none', null: false
      t.index :simulator_instance_id
    end
    SimulatorInstance.all.each { |s| ControlVariateState.create!(state: 'none', simulator_instance_id: s.id) }
  end

  def down
    drop_table :control_variate_states
  end
end
