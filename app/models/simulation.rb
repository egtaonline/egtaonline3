class Simulation < ActiveRecord::Base
  attr_accessible :error_message, :job_id, :profile_id, :qos, :scheduler_id, :size, :state
end
