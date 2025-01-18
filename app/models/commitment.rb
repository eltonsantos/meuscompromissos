class Commitment < ApplicationRecord
  belongs_to :user

  has_many :tasks, dependent: :destroy
  has_many :task_histories, dependent: :destroy

  validates :description, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def update_progress
    total_tasks = tasks.size
    return self.progress = 0 if total_tasks.zero?

    completed_tasks = tasks.select(&:completed?).size
    self.progress = (completed_tasks.to_f / total_tasks * 100).round(2)
    save
  end

  def time_remaining
    remaining_time = created_at + 7.days - Time.current
    return "Expirado" if remaining_time <= 0

    days = (remaining_time / 1.day).to_i
    hours = ((remaining_time % 1.day) / 1.hour).to_i

    days_text = days == 1 ? "#{days} dia" : "#{days} dias"
    hours_text = hours == 1 ? "#{hours} hora" : "#{hours} horas"

    "#{days_text} e #{hours_text}"
  end
end
