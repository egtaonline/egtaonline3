class AddSubgamesToGames < ActiveRecord::Migration
  def change
    add_column :games, :subgames, :json
  end
end
