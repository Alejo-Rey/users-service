class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def authenticate_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue StandardError
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
