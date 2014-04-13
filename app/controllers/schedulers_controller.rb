class SchedulersController < ProfileSpacesController
  expose(:schedulers) do
    klass.includes(:simulator_instance)
      .order("#{sort_column} #{sort_direction}#{secondary_column}")
      .page(params[:page])
  end
  expose(:scheduler, attributes: :scheduler_parameters) do
    id = params["#{model_name}_id"] || params[:id]
    if id
      klass.find(id)
    else
      klass.new(params[model_name])
    end
  end

  expose(:role_owner) { scheduler }
  expose(:role_owner_path) { "/schedulers/#{scheduler.id}" }

  expose(:scheduling_requirements) do
    SchedulingRequirement.where(scheduler_id: params[:id])
      .includes(:profile).order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end

  def create
    @scheduler = SchedulerBuilder.create(
      klass, scheduler_parameters, params[:selector][:simulator_id],
      params[:selector][:configuration])
    respond_with(@scheduler)
  end

  def update
    @scheduler = klass.find(params[:id])
    @scheduler = SchedulerBuilder.update(
      @scheduler, scheduler_parameters, params[:selector][:configuration])
    respond_with(@scheduler)
  end

  def destroy
    scheduler.destroy
    respond_with(scheduler)
  end

  def create_game_to_match
    @scheduler = klass.find(params[:id])
    if Game.find_by(simulator_instance_id: scheduler.simulator_instance_id,
                    name: scheduler.name)
      flash[:alert] = 'A game with that name already exists.'
      respond_with(@scheduler)
    else
      respond_with(GameBuilder.create_game_to_match(@scheduler))
    end
  end

  private

  def scheduler_parameters
    params.require(model_name.to_sym).permit(
      :active, :name, :nodes, :process_memory, :observations_per_simulation,
      :size, :time_per_observation,
      :default_observation_requirement, :simulator_instance_id)
  end

  def sort_column
    if params[:id]
      params[:sort] ||= 'profiles.assignment'
    else
      super
    end
  end

  def default_secondary
    ', name ASC'
  end
end
