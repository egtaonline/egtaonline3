class AddingFeatureIndexes < ActiveRecord::Migration
  def up
    execute 'CREATE INDEX obs_feat_idx ON observations USING GIN (features);
      CREATE INDEX player_feat_idx ON players USING GIN (features);'
  end

  def down
    execute 'DROP INDEX obs_feat_idx;
             DROP INDEX player_feat_idx;'
  end
end
