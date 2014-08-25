class AnalysesController < AuthenticatedController
  expose(:analyses) do
    Analysis.order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end
  expose(:analysis)

  private

  def default_order
    'id'
  end
end
