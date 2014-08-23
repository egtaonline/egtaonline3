class AddEnableSubgameToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :enable_subgame, :boolean
  end
end
