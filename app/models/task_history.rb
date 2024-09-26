class TaskHistory < ApplicationRecord
  belongs_to :task
  belongs_to :commitment
end
