class SchedulersController < ProfileSpacesController
  expose(:schedulers){ klass.joins(:simulator_instance).order("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:scheduler) do
    if id = params["#{model_name}_id"] || params[:id]
      klass.find(id)
    else
      klass.new(params[model_name])
    end
  end

  expose(:role_owner){ scheduler }
  expose(:role_owner_path){ "/schedulers/#{scheduler.id}" }

  expose(:scheduling_requirements) do
    SchedulingRequirement.joins(:profile).where(scheduler_id: params[:id]).order("#{sort_column} #{sort_direction}").page(params[:page])
  end

  def create
    @scheduler = SchedulerFactory.create(klass, scheduler_parameters, params[:selector][:simulator_id], params[:selector][:configuration])
    respond_with(@scheduler)
  end

  def update
    @scheduler = klass.find(params[:id])
    @scheduler = SchedulerFactory.update(@scheduler, scheduler_parameters, params[:selector][:configuration])
    respond_with(@scheduler)
  end

  def create_game_to_match
    @scheduler = klass.find(params[:id])
    respond_with(GameFactory.create_game_to_match(@scheduler))
  end

  private

  def scheduler_parameters
    params.require(model_name.to_sym).permit(:active, :name, :nodes, :process_memory, :observations_per_simulation, :size, :time_per_observation,
                    :default_observation_requirement, :simulator_instance_id)
  end

  def sort_column
    if params[:id]
      params[:sort] ||= "assignment"
    else
      super
    end
  end
end