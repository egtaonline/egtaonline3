class Api::V3::GenericSchedulersController < Api::V3::BaseController
  before_filter :find_object, only: [:show, :edit, :destroy, :add_profile,
    :add_role, :remove_role]

  def add_profile
    profile = @object.add_profile(params[:assignment], params[:count])
    respond_with(profile, status: (profile.errors.messages.empty? ? 201 : 422),
      location: nil)
  end
end