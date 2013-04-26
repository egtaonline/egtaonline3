class SchedulersController < AuthenticatedController
  include SimulatorSelector
  before_filter :merge, only: [:create, :update]

  expose(:schedulers){ klass.joins(:simulator_instance).order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:scheduler) do
    if id = params["#{model_name}_id"] || params[:id]
      klass.find(id).tap do |r|
        r.attributes = params[model_name] unless request.get?
      end
    else
      klass.new(params[model_name])
    end
  end

  expose(:scheduling_requirements) do
    SchedulingRequirement.joins(:profile).where(scheduler_id: params[:id]).order("#{sort_column} #{sort_direction}").page(params[:page])
  end

  def create
    scheduler = klass.create_with_simulator_instance(params[model_name])
    respond_with(scheduler)
  end

  private

  def merge
    params[model_name] = params[model_name].merge(params[:selector])
  end
  
  def sort_column
    if params[:id]
      params[:sort] ||= "assignment"
    else
      super
    end
  end
end