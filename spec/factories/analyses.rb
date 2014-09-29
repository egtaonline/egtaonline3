require 'json'

FactoryGirl.define do
	factory :analysis do
		game
		sequence(:error_message) {|n| "Error#{n}"}
		sequence(:job_id)
		output 'output_fake'
		subgame 1.to_json 
	end

	trait :running_status do
		status 'running'
	end	

	trait :queued_status do
		status 'queued'
	end

	trait :pending_status do
		status 'pending'
	end

	trait :failed_status do
		status 'failed'
	end
end