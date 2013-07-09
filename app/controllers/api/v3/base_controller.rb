class Api::V3::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!
  before_filter :find_object, only: [:show, :edit, :destroy]

  def show
  end

  private

  def model_name
    @model_name ||= params[:controller].singularize.classify.demodulize
  end

  def klass
    @klass ||= model_name.constantize
  end

  def find_object
    begin
      @object = klass.find(params[:id])
    rescue
      render json: {error:
        "the #{model_name} you were looking for could not be found"}.to_json,
        status: 404
    end
  end

  def validate_param(param_symbol)
    if params[param_symbol] == nil || params[param_symbol] == ""
      respond_with({ error: "you did not specify a #{param_symbol}" },
        status: 422, location: nil)
    end
  end
end