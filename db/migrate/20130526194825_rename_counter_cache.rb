class RenameCounterCache < ActiveRecord::Migration
  def change
    rename_column :profiles, :observation_count, :observations_count
  end
end
