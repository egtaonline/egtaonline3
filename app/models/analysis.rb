class Analysis < ActiveRecord::Base
	belongs_to :game
	has_one :anaysis_script
	has_one :reduction_script
	has_one :subgame_script
	has_one :dominance_script
	has_one :pbs
end
