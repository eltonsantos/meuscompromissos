require "test_helper"

class CronControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["CRON_TOKEN"]
    ENV["CRON_TOKEN"] = "test-token-123"
  end

  teardown do
    ENV["CRON_TOKEN"] = @previous_token
  end

  test "retorna 401 sem token" do
    post "/cron/run"
    assert_response :unauthorized
  end

  test "retorna 401 com token invalido" do
    post "/cron/run", headers: { "X-Cron-Token" => "errado" }
    assert_response :unauthorized
  end

  test "executa com token valido" do
    NotificationDispatcher.stub :dispatch_all, { users_processed: 0, notifications_sent: 0, subscriptions_removed: 0 } do
      CommitmentManagementJob.stub_any_instance(:perform, nil) do
        post "/cron/run", headers: { "X-Cron-Token" => "test-token-123" }
      end
    end
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "ok", body["status"]
  end
end

class CommitmentManagementJob
  def self.stub_any_instance(method, return_value)
    original = instance_method(method)
    define_method(method) { |*_args| return_value }
    yield
  ensure
    define_method(method, original)
  end
end
