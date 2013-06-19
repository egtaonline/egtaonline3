class Role < ActiveRecord::Base
  belongs_to :role_owner, :polymorphic => true
end
