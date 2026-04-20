class NotificationDispatcher
  EXPIRATION_WARNING_DAYS = 2
  COMMITMENT_LIFETIME_DAYS = 7

  def self.dispatch_all
    summary = { users_processed: 0, notifications_sent: 0, subscriptions_removed: 0 }

    User.joins(:push_subscriptions).distinct.find_each do |user|
      result = new(user).call
      summary[:users_processed] += 1
      summary[:notifications_sent] += result[:sent]
      summary[:subscriptions_removed] += result[:removed]
    end

    summary
  end

  def initialize(user)
    @user = user
  end

  def call
    sent = 0
    removed = 0

    payloads.each do |payload|
      @user.push_subscriptions.each do |subscription|
        if deliver(subscription, payload)
          sent += 1
        else
          subscription.destroy
          removed += 1
        end
      end
    end

    { sent: sent, removed: removed }
  end

  private

  def payloads
    list = []

    expiring = expiring_commitments
    if expiring.any?
      list << {
        title: "Compromisso prestes a expirar",
        body: build_expiring_body(expiring),
        path: "/"
      }
    end

    in_progress_count = in_progress_tasks_count
    if in_progress_count.positive?
      list << {
        title: "Tarefas pendentes",
        body: "Voce tem #{in_progress_count} #{in_progress_count == 1 ? 'tarefa em andamento' : 'tarefas em andamento'} hoje.",
        path: "/"
      }
    end

    list
  end

  def expiring_commitments
    threshold = (COMMITMENT_LIFETIME_DAYS - EXPIRATION_WARNING_DAYS).days.ago
    @user.commitments.where(active: true).where("created_at <= ?", threshold)
  end

  def in_progress_tasks_count
    Task.joins(:commitment)
        .where(commitments: { user_id: @user.id, active: true })
        .where(status: Task.statuses[:in_progress])
        .count
  end

  def build_expiring_body(commitments)
    if commitments.size == 1
      "1 compromisso esta a #{EXPIRATION_WARNING_DAYS} dias ou menos de expirar."
    else
      "#{commitments.size} compromissos estao a #{EXPIRATION_WARNING_DAYS} dias ou menos de expirar."
    end
  end

  def deliver(subscription, payload)
    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: ENV.fetch("VAPID_SUBJECT", "mailto:admin@example.com"),
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"]
      },
      ttl: 24 * 60 * 60
    )
    true
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription, WebPush::Unauthorized => e
    Rails.logger.warn "[NotificationDispatcher] Removendo subscription #{subscription.id}: #{e.class.name} - #{e.message}"
    false
  rescue => e
    Rails.logger.error "[NotificationDispatcher] Falha ao enviar para subscription #{subscription.id}: #{e.class.name} - #{e.message}"
    true
  end
end
