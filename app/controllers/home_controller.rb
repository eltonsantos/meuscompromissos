class HomeController < ApplicationController
  
  def index
    @tasks = Task.joins(commitment: :user).where(users: { id: current_user.id }).where(commitments: { active: true })
  end
end
