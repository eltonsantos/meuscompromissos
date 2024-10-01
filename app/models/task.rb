class Task < ApplicationRecord
  belongs_to :category
  belongs_to :commitment

  after_save :update_commitment_progress
  after_destroy :update_commitment_progress

  has_many :task_histories, dependent: :destroy

  enum status: { in_progress: 0, archived: 1, completed: 2 }

  validates :title, presence: true
  validates :hours, numericality: { greater_than: 0, allow_blank: true }

  def update_commitment_progress
    commitment.update_progress
  end

  def formatted_hours
    total_minutes = (hours * 60).round
    hours = total_minutes / 60
    minutes = total_minutes % 60

    hours_text = hours == 1 ? "#{hours} hora" : "#{hours} horas"
    minutes_text = minutes == 1 ? "#{minutes} minuto" : "#{minutes} minutos"

    if hours > 0 && minutes > 0
      "#{hours_text} e #{minutes_text}"
    elsif hours > 0
      hours_text
    else
      minutes_text
    end
  end
end
