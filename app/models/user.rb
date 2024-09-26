class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :commitments, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :hours_per_week, numericality: { greater_than: 0 }

  def has_active_commitments?
    commitments.where(active: true).exists?
  end
end
