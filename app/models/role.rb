class Role < ActiveRecord::Base
  attr_accessible :count, :name, :reduced_count, :strategies, :deviating_strategies
  belongs_to :role_owner, :polymorphic => true
end
