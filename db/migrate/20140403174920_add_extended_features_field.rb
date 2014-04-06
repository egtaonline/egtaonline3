class AddExtendedFeaturesField < ActiveRecord::Migration
  def change
    change_table :observations do |t|
      t.rename :features, :extended_features
      t.hstore :features
    end

    change_table :players do |t|
      t.rename :features, :extended_features
      t.hstore :features
    end
  end
end
