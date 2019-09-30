class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      log_in user
      redirect_to user_funds_path(user)
    else
      render '/'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
