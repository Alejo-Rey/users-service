class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: { token: token, message: "Login successful" }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def validate
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    raise unless token

    begin
      decoded_token = JwtService.decode(token)
      current_user = User.find(decoded_token[:user_id])

      if current_user.present?
        render json: { token: token,
                       message: "Authorized",
                       user: { "id": current_user.id, "email": current_user.email } },
               status: :ok
      else
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    rescue StandardError => e
      render json: { error: "Unauthorized: #{e}" }, status: :unauthorized
    end
  end
end
