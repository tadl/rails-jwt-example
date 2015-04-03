class JwtController < ApplicationController
  # inspired partially by examples from https://auth0.com/docs/server-apis/rails

  class InvalidTokenError < StandardError; end

  def whoami
    if session[:cards].nil?
      render :json => { :error => "Not authenticated." }, status: :unauthorized
    else
      render :json => { :cards => session[:cards] }
    end
  end

  def auth
    begin
      token = params[:token] # get token from HTTP request
      raise InvalidTokenError if token.nil?

      decoded_token = JWT.decode(token, ENV['JWT_SECRET'])

      @user = decoded_token

      session[:cards] = @user[0]["http://tadl.org/patron-cards"]

      redirect_to action: 'whoami'

    rescue JWT::DecodeError, InvalidTokenError
      render :json => { :error => "Unauthorized: Invalid token." }, status: :unauthorized
    end
  end

  def logout
    session.clear
    render :json => { :message => "Logged out" }
  end

end
