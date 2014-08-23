class AddEnableReductionToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :enable_reduction, :boolean
  end
end
