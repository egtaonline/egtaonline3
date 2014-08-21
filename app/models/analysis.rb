class Analysis < ActiveRecord::Base
	belongs_to :game
	has_one :anaysis_script, dependent: :destroy
	has_one :reduction_script, dependent: :destroy
	has_one :subgame_script, dependent: :destroy
	has_one :dominance_script, dependent: :destroy
	has_one :pbs, dependent: :destroy
end
