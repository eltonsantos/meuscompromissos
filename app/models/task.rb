class Task < ApplicationRecord
  belongs_to :category
  belongs_to :commitment

  has_many :task_histories, dependent: :destroy

  validates :title, presence: true
  validates :hours, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [ true, false ] }
  validates :archived, inclusion: { in: [ true, false ] }
end
