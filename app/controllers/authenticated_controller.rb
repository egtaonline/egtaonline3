class AuthenticatedController < ApplicationController
  respond_to :html
  before_filter :authenticate_user!
  expose(:model_name){ params[:controller].singularize }
  expose(:klass){ model_name.classify.constantize }
  helper_method :sort_column, :sort_direction

  private

  def sort_direction
    %w[ASC DESC].include?(params[:direction]) ? params[:direction] : "ASC"
  end

  def sort_column
    params[:sort] ||= default_order
  end

  def default_order
    "name"
  end
end