class AuthenticatedController < ApplicationController
  respond_to :html, :js
  before_filter :authenticate_user!
  expose(:flux_connection){ FluxConnection.first }
  expose(:model_name){ params[:controller].singularize }
  expose(:klass){ model_name.classify.constantize }
  helper_method :sort_column, :sort_direction

  private

  def sort_direction
    %w(ASC DESC).include?(params[:direction]) ? params[:direction] : "ASC"
  end

  def sort_column
    params[:sort] ||= default_order
  end

  def default_order
    "name"
  end

  def default_secondary
    ""
  end

  def secondary_column
    params[:secondary_column] ||= default_secondary
  end
end