class AddEmailToPbs < ActiveRecord::Migration
  def change
    add_column :pbs, :user_email, :text
  end
end
