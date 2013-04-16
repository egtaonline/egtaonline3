class AuthenticatedController < ApplicationController
  respond_to :html
  before_filter :authenticate_user!
  expose(:model_name){ params[:controller].singularize }
end