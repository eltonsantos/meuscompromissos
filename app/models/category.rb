class Category < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
