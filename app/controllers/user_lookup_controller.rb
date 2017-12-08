class UserLookupController < ApplicationController
  before_action :authenticate_user!

  def ldap
    if user = User.find_or_create_by_username(params[:netid])
      if Pundit.policy(current_user, user).edit?
        redirect_to edit_user_path(user)
      else
        flash[:notice] = "User `#{params[:netid]}` created"
        redirect_to root_path
      end
    else
      flash[:alert] = "No user found with username #{params[:netid].inspect}"
      redirect_to new_user_path
    end
  end
end
