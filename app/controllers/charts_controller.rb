class ChartsController < ApplicationController
  def index
    all_tasks = current_user.commitments.flat_map(&:tasks)
    
    @total_tasks = all_tasks.size
    @completed_tasks = all_tasks.count { |task| task.completed? }
    @in_progress_tasks = all_tasks.count { |task| task.in_progress? }
    @archived_tasks = all_tasks.count { |task| task.archived? }

    categories_count = all_tasks.group_by { |task| task.category.name }
                                .transform_values(&:count)
    
    respond_to do |format|
      format.html
      format.json { 
        render json: {
          total: @total_tasks,
          completed: @completed_tasks,
          in_progress: @in_progress_tasks,
          archived: @archived_tasks,
          categories: categories_count
        }
      }
    end
  end
end