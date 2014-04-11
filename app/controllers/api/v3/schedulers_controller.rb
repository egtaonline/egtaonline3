class Api::V3::SchedulersController < Api::V3::BaseController
  def show
    render json: SchedulerPresenter.new(@object)
            .to_json(granularity: params[:granularity]),
           status: 200
  end
end
