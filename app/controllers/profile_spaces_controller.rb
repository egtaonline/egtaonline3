class ProfileSpacesController < AuthenticatedController
  def update_configuration
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js { render 'configuration/update_configuration' }
    end
  end

  def duplicate
    s = role_owner.dup
    s.name = params[model_name][:name]
    if model_name.include? "scheduler"
      s.active = false
    end

    if s.save
      for role in role_owner.roles
        r = role.dup
        r.role_owner_id = s.id
        s.roles << r
      end
      respond_with(s)
    else
      flash[:alert] = "A #{model_name == "game" ? "game" : "scheduler"} with the name '#{params[model_name][:name]}' already exists."
      redirect_to :back
    end
  end

end
