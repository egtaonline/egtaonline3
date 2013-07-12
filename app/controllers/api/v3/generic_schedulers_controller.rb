class Api::V3::GenericSchedulersController < Api::V3::SchedulersController
  include Api::V3::RoleManipulator

  before_filter :find_object, only: [:show, :update, :destroy, :add_profile,
    :remove_profile, :add_role, :remove_role]
  before_filter :role_exists, only: :add_role

  def index
    render json: {generic_schedulers: GenericScheduler.all}, status: 200
  end

  def create
    @scheduler = SchedulerFactory.create(klass, scheduler_parameters,
      params[:scheduler][:simulator_id], params[:scheduler][:configuration])
    respond_with(@scheduler)
  end

  def update
    @object.update_attributes(scheduler_parameters)
    respond_with(@object)
  end

  def destroy
    @object.destroy
    respond_with(@object)
  end

  def add_profile
    profile = @object.add_profile(params[:assignment], params[:count])
    respond_with(profile, status: (profile.errors.messages.empty? ? 201 : 422),
      location: nil)
  end

  def remove_profile
    @object.remove_profile_by_id(params[:profile_id])
    render json: nil, status: 204
  end

  private

  def scheduler_parameters
    params.require(:scheduler).permit(:active, :name, :nodes, :process_memory,
      :observations_per_simulation, :size, :time_per_observation,
      :default_observation_requirement)
  end
end