class SessionsController < ApplicationController
include SessionsHelper
	

  def new
      
  end

  def create

    user = User.find_by(email: params[:email])
     if user and user.authenticate(params[:password])
     session[:user_id] = user.id
     redirect_to new_rule_path, notice: "You have logged in as #{user.email}"
    else

    redirect_to sessions_new_path, alert: "Invalid user/password combination"
 end

  end

  def destroy
      session[:user_id] = nil
  end

  



end
