class ApplicationController < ActionController::Base
  expose(:title) { "EGTAOnline" }
  protect_from_forgery

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end
end
