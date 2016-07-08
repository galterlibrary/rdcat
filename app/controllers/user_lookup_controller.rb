class UserLookupController < ApplicationController

  def ldap
    user = User.find_or_create_by_username(params[:netid])
    if user 
      redirect_to edit_user_path(user)
    else
      flash[:alert] = "No user found with username #{params[:netid].inspect}"
      redirect_to new_user_path
    end

  end

end