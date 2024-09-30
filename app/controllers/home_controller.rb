class HomeController < ApplicationController
  
  def index
    @tasks = current_user.commitments.includes(:tasks).flat_map(&:tasks)
  end
end
