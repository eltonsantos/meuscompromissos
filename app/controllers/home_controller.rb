class HomeController < ApplicationController
  
  def index
    @tasks = Task.all
    @commitments = current_user.commitments.includes(:tasks)
    
    @total_tasks = @commitments.flat_map(&:tasks).size
    @in_progress = @commitments.flat_map(&:tasks).select { |task| task.in_progress? }.size
    @completed = @commitments.flat_map(&:tasks).select { |task| task.completed? }.size
    @archived = @commitments.flat_map(&:tasks).select { |task| task.archived? }.size
    @progress_percentage = @total_tasks.zero? ? 0 : (@completed.to_f / @total_tasks * 100).round(2)
  end
end
