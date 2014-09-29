# FactoryGirl.define do
# 	factory :analysis_script do 

# 		analysis = create(:analysis, :running_status)
# 		analysis.create_analysis_script()

# 		regret 0.1 
# 		dist 0.1
# 		support 0.1
# 		converge 0.2
# 		iters 10
# 		points 6
# 		enable_dominance true
# 		analysis_id 1		

# 		# trait :with_running do
# 		# 	analysis { create(:analysis, :running_status) }
# 		# end
	
# 		trait :with_verbose do
# 			verbose true
# 		end

# 		trait :without_verbose do
# 			verbose false
# 		end

# 		trait :with_dominance do
# 			enable_dominance true
# 		end

# 		trait :without_dominance do
# 			enable_dominance false
# 		end

		
# 	end
# end