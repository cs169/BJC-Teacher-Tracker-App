class AdminController < ApplicationController
  def new
    @administrator = Administrator.new
  end

  def create
    @administrator = Administrator.new(params[:user])
    if @administrator.save
      flash[:notice] = "You signed up successfully"
      flash[:color]= "valid"
    else
      flash[:notice] = "Form is invalid"
      flash[:color]= "invalid"
    end
    render "new"
  end

  def googleAuth
    # Get access tokens from the google server
    access_token = request.env["omniauth.auth"]
    adminastrator = Adminastrator.from_omniauth(access_token)
    log_in(admin)
    # Access_token is used to authenticate request made from the rails application to the google server
    adminastrator.google_token = access_token.credentials.token
    # Refresh_token to request new access_token
    # Note: Refresh_token is only sent once during the first request
    refresh_token = access_token.credentials.refresh_token
    user.google_refresh_token = refresh_token if refresh_token.present?
    adminastrator.save
    redirect_to root_path
  end
end