class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_available_hours

  protected

  def set_available_hours
    return unless user_signed_in?

    commitments = current_user.commitments.includes(:tasks)
    total_hours_used = commitments.flat_map(&:tasks).pluck(:hours).sum || 0
    @available_hours = current_user.hours_per_week - total_hours_used
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :hours_per_week])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :hours_per_week])
  end
end
