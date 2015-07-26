class AuthController < ApplicationController
  #skip_before_action :authenticate_request # this will be implemented later

  def signup
    user = User.new(user_params)
    if user.save
      render json: { user: user,
                     token: user.generate_auth_token }
    else
      render json: { errors: user.errors }
    end
  end

  def authenticate
    user = User.find_by_credentials(params[:email], params[:password])
    if user
      render json: { auth_token: user.generate_auth_token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

    def user_params
      params.permit(:email, :password, :password_confirmation, :first_name, :last_name, :device_token)
    end
end
