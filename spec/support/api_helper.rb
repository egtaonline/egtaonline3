# Module to pull in Rack::Test for RSpec
module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end

RSpec.configure do |c|
  c.include ApiHelper, type: :api
end
