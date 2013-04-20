class AddTypeToSchedulers < ActiveRecord::Migration
  def change
    add_column :schedulers, :type, :string, :null => false
  end
end
