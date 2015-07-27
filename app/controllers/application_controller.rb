class ApplicationController < ActionController::Base
  require 'auth_token.rb'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  #skip_before_filter  :verify_authenticity_token
  before_action :set_current_user, :authenticate_request, :except => [:pushTest, :authenticate, :signup]

  # rescue_from NotAuthenticatedError do
  rescue_from StandardError do
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end
  # rescue_from AuthenticationTimeoutError do
  rescue_from StandardError do
    render json: { error: 'Auth token is expired' }, status: 419 # unofficial timeout status code
  end

  private

  # Based on the user_id inside the token payload, find the user.
  def set_current_user
    if decoded_auth_token
      @current_user ||= User.find(decoded_auth_token[:user_id])
    end
  end

  # Check to make sure the current user was set and the token is not expired
  def authenticate_request
    if auth_token_expired?
      # fail AuthenticationTimeoutError
      fail StandardError
    elsif !@current_user
      # fail NotAuthenticatedError
      fail StandardError
    end
  end

  def decoded_auth_token
    @decoded_auth_token ||= AuthToken.decode(http_auth_header_content)
  end

  def auth_token_expired?
    decoded_auth_token && decoded_auth_token.expired?
  end

  # JWT's are stored in the Authorization header using this format:
  # Bearer somerandomstring.encoded-payload.anotherrandomstring
  def http_auth_header_content
    return @http_auth_header_content if defined? @http_auth_header_content
    @http_auth_header_content = begin
      if request.headers['Authorization'].present?
        request.headers['Authorization'].split(' ').last
      else
        nil
      end
    end
  end

  class NotAuthenticatedError < StandardError; end
  class AuthenticationTimeoutError < StandardError; end
end
