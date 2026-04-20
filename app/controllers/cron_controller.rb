class CronController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :authenticate_cron_request!

  def run
    started_at = Time.current
    Rails.logger.info "[CronController] Disparado em #{started_at}"

    CommitmentManagementJob.new.perform
    summary = NotificationDispatcher.dispatch_all

    render json: {
      status: "ok",
      ran_at: started_at,
      duration_ms: ((Time.current - started_at) * 1000).round,
      notifications: summary
    }
  rescue => e
    Rails.logger.error "[CronController] Erro: #{e.class.name} - #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    render json: { status: "error", error: e.message }, status: :internal_server_error
  end

  private

  def authenticate_cron_request!
    expected = ENV["CRON_TOKEN"].to_s
    provided = request.headers["X-Cron-Token"].to_s

    if expected.empty? || !ActiveSupport::SecurityUtils.secure_compare(expected, provided)
      render json: { status: "unauthorized" }, status: :unauthorized
    end
  end
end
