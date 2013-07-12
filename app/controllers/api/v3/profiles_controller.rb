class Api::V3::ProfilesController < Api::V3::BaseController
  def show
    render json: ProfilePresenter.new(@object).to_json(
      granularity: params[:granularity]), status: 200
  end
end