module Api::V3::RoleManipulator
  def add_role
    role = @object.add_role(params[:role], params[:count])
    respond_with(role, status: (role.valid? ? 204 : 422), location: nil)
  end

  def remove_role
    @object.remove_role(params[:role])
    render json: nil, status: 204
  end

  protected

  def role_exists
    unless @object.simulator.role_configuration[params[:role]]
      respond_with({ error: 'the Role you wished to add was not found' \
        " on the #{model_name}'s Simulator" }, status: 422, location: nil)
    end
  end
end
