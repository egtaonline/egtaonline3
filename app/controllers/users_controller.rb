class UsersController < AuthenticatedController
  before_filter :verify_admin, only: :index
  expose(:users) do
    User.where(approved: false).order(
      "#{sort_column} #{sort_direction}").page(params[:page])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(user_params)
    if current_user.admin?
      redirect_to '/users'
    else
      respond_with(@user)
    end
  end

  private

  def user_params
    list = [:email, :password, :password_confirmation]
    list << :approved if current_user.admin?
    params.require(:user).permit(list)
  end

  def verify_admin
    unless current_user.admin?
      flash[:alert] = 'You must be an admin to visit that page.'
      redirect_to '/'
    end
  end

  def default_order
    'email'
  end
end