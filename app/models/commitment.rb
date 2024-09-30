class Commitment < ApplicationRecord
  belongs_to :user

  has_many :tasks, dependent: :destroy
  has_many :task_histories, dependent: :destroy

  validates :description, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def check_active_status
    if active && created_at < 7.days.ago
      update(active: false)
    end
  end
end
