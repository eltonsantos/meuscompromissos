class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :commitments, dependent: :destroy
  has_many :categories, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :hours_per_week, numericality: { greater_than: 0, allow_blank: true }

  def has_active_commitments?
    commitments.where(active: true).exists?
  end

  def formatted_hours_per_week
    total_minutes = (hours_per_week * 60).round
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

  def formatted_available_hours(available_hours)
    total_minutes = (available_hours * 60).round
    hours = total_minutes / 60
    minutes = total_minutes % 60

    hours_text = hours == 1 ? "1 hora" : "#{hours} horas"
    minutes_text = minutes == 1 ? "1 minuto livre" : "#{minutes} minutos"

    if hours > 0 && minutes > 0
      "#{hours_text} e #{minutes_text} livres no seu dia"
    elsif hours == 1
      "#{hours_text} livre no seu dia"
    elsif hours > 0
      "#{hours_text} livres no seu dia"
    else
      "#{minutes_text} no seu dia"
    end
  end
end
