module Api::V3::StrategyManipulator
  def add_strategy
    @object.add_strategy(params[:role], params[:strategy])
    render json: nil, status: 204
  end

  def remove_strategy
    @object.remove_strategy(params[:role], params[:strategy])
    render json: nil, status: 204
  end
end
