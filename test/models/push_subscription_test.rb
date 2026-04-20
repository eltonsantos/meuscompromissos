require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  def user
    @user ||= User.create!(
      name: "Push Tester",
      email: "push_tester_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      hours_per_week: 40
    )
  end

  test "valida presenca de campos obrigatorios" do
    sub = PushSubscription.new
    assert_not sub.valid?
    assert_includes sub.errors[:endpoint], "can't be blank"
    assert_includes sub.errors[:p256dh_key], "can't be blank"
    assert_includes sub.errors[:auth_key], "can't be blank"
  end

  test "exige endpoint unico" do
    user.push_subscriptions.create!(endpoint: "https://push.example/abc", p256dh_key: "p", auth_key: "a")
    duplicate = user.push_subscriptions.build(endpoint: "https://push.example/abc", p256dh_key: "p", auth_key: "a")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:endpoint], "has already been taken"
  end
end
