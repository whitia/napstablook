class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      log_in user
      redirect_to user
    else
      # エラーメッセージを作成する
      render 'new'
    end
  end

  def destroy
  end
end
