class SwitchAssignmentToText < ActiveRecord::Migration
  def change
    change_column :profiles, :assignment, :text
  end
end
