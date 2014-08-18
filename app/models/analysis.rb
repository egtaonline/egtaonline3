class Analysis < ActiveRecord::Base
	belongs_to :game
	has_one :anaysis_script
	has_one :reduction_script
	belongs_to :subgame_script
end
