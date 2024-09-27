class HomeController < ApplicationController
  
  def index
    @tasks = Task.all.order(:id)
  end
end
