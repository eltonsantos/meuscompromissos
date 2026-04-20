require "test_helper"

class NotificationDispatcherTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Notif Tester",
      email: "notif_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      hours_per_week: 40
    )
    @category = Category.create!(name: "Cat", user: @user)
  end

  test "nao gera payload quando nao ha gatilhos" do
    Commitment.create!(user: @user, description: "Recente", active: true, created_at: 1.day.ago)
    dispatcher = NotificationDispatcher.new(@user)
    assert_equal [], dispatcher.send(:payloads)
  end

  test "gera payload de compromisso expirando" do
    Commitment.create!(user: @user, description: "Antigo", active: true, created_at: 6.days.ago)
    dispatcher = NotificationDispatcher.new(@user)
    payloads = dispatcher.send(:payloads)
    assert payloads.any? { |p| p[:title].include?("expirar") }, "esperava payload de expiracao"
  end

  test "gera payload de tarefas em andamento" do
    commitment = Commitment.create!(user: @user, description: "Recente", active: true, created_at: 1.day.ago)
    Task.create!(title: "T1", hours: 1, status: :in_progress, commitment: commitment, category: @category)
    dispatcher = NotificationDispatcher.new(@user)
    payloads = dispatcher.send(:payloads)
    assert payloads.any? { |p| p[:title] == "Tarefas pendentes" }, "esperava payload de tarefas pendentes"
  end

  test "ignora tarefas concluidas e arquivadas" do
    commitment = Commitment.create!(user: @user, description: "Recente", active: true, created_at: 1.day.ago)
    Task.create!(title: "T1", hours: 1, status: :completed, commitment: commitment, category: @category)
    Task.create!(title: "T2", hours: 1, status: :archived, commitment: commitment, category: @category)
    dispatcher = NotificationDispatcher.new(@user)
    payloads = dispatcher.send(:payloads)
    assert_equal [], payloads
  end
end
