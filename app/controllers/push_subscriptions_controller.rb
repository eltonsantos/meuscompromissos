class PushSubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(endpoint: subscription_params[:endpoint])
    subscription.p256dh_key = subscription_params[:p256dh_key]
    subscription.auth_key   = subscription_params[:auth_key]

    if subscription.save
      render json: { status: "ok", id: subscription.id }, status: :created
    else
      render json: { status: "error", errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.push_subscriptions.find_by(endpoint: params[:endpoint])
    subscription&.destroy
    render json: { status: "ok" }
  end

  private

  def subscription_params
    permitted = params.permit(:endpoint, :p256dh_key, :auth_key, subscription: [:endpoint, keys: [:p256dh, :auth]])

    if permitted[:subscription].present?
      sub = permitted[:subscription]
      keys = sub[:keys] || {}
      {
        endpoint:   sub[:endpoint],
        p256dh_key: keys[:p256dh],
        auth_key:   keys[:auth]
      }
    else
      {
        endpoint:   permitted[:endpoint],
        p256dh_key: permitted[:p256dh_key],
        auth_key:   permitted[:auth_key]
      }
    end
  end
end
