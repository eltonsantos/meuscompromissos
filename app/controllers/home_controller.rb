class HomeController < ApplicationController
  
  def index
    @tasks = Task.joins(commitment: :user).where(users: { id: current_user.id })
  end
end
