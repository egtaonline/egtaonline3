FactoryGirl.define do
	factory :analysis_script do
		verbose true
		regret 0.1 
		dist 0.1
		support 0.1
		converge 0.2
		iters 10
		points 6
		enable_dominance true
		analysis
	end
end