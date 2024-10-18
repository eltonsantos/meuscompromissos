namespace :commitments do
  desc "Check for expired commitments and deactivate them"
  task check_expired: :environment do
    Commitment.where(active: true).each do |commitment|
      if commitment.created_at < 7.days.ago
        commitment.update(active: false)
      end
    end
  end
end
