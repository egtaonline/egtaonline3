class AddSimulatorFullnameToSimulatorInstance < ActiveRecord::Migration
  def change
    add_column :simulator_instances, :simulator_fullname, :string, :null => false
  end
end
