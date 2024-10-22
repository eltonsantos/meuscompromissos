# class CommitmentExpirationCheckJob < ApplicationJob
#   queue_as :default

#   def perform(commitment_id)
#     commitment = Commitment.find_by(id: commitment_id)

#     return unless commitment

#     if commitment.active && commitment.created_at < 7.days.ago
#       commitment.update(active: false)
#     end
#   end
# end
