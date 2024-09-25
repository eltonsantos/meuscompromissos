class TaskHistory < ApplicationRecord
  belongs_to :task
  belongs_to :commitment

  validates :start_date, presence: true
end
