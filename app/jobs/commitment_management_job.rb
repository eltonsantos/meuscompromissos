class CommitmentManagementJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "########### Starting CommitmentManagementJob at #{Time.current}"

    # Encontra compromissos ativos que já passaram de 7 dias
    expired_commitments = Commitment.where(active: true).where("created_at <= ?", 7.days.ago)

    Rails.logger.info "########### Found #{expired_commitments.count} expired commitments"
  
    expired_commitments.each do |commitment|
      ActiveRecord::Base.transaction do
        commitment.update!(active: false)

        new_commitment = Commitment.create!(
          description: "Novo compromisso iniciado em #{Time.current.strftime('%d/%m/%Y')}",
          user: commitment.user,
          active: true
        )

        # TODO: Transferir tarefas não concluídas para o novo compromisso
        commitment.tasks.where(status: [:archived, :in_progress]).each do |task|
          task.update!(commitment: new_commitment)
        end
      end
    end

    Rails.logger.info "########### CommitmentManagementJob completed"
  end
end