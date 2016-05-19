class AddEnableLearningToAnalyses < ActiveRecord::Migration
  def change
  	add_column :analyses, :enable_learning, :boolean
  end
end
