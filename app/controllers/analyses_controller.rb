class AnalysesController < AuthenticatedController

  expose(:analyses) {index}

  expose(:analysis)

  def index
    @default_search_column = "Game"

    a = params[:game_id] ? Game.find(params[:game_id]).analyses : Analysis
    if params[:search]
      a = a.search(params[:search])
    end
    a.order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end

  def show
    respond_to do |format|
      format.html do
      end

      format.json do
        file_name = AnalysisPresenter.new(analysis).get_output(output: params[:output])
        send_file file_name, type: 'text'
      end
    end
  end

  private

  def default_order
    'id'
  end
end
