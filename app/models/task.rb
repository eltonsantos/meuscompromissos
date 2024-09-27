class Task < ApplicationRecord
  belongs_to :category
  belongs_to :commitment

  has_many :task_histories, dependent: :destroy

  enum status: { in_progress: 0, archived: 1, completed: 2 }

  validates :title, presence: true
  validates :hours, numericality: { greater_than: 0, allow_blank: true }
end
