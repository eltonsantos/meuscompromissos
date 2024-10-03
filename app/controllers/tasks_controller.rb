class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy mark_completed archive unarchive ]

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @categories = current_user.categories.distinct
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)
    
    @task.commitment = current_user.commitments.where(active: true).find_by(active: true)

    if hours_exceed_limit?(@task.hours)
      flash[:alert] = "Você não tem horas livres suficientes para cadastrar essa tarefa."
      render :new and return
    end

    respond_to do |format|
      if @task.save
        TaskHistory.create(task: @task, commitment: @task.commitment)
        format.html { redirect_to root_path, notice: "Tarefa foi criada com sucesso." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update

    previous_hours = @task.hours

    if hours_exceed_limit?(task_params[:hours].to_f, previous_hours)
      flash[:alert] = "Você não tem horas livres suficientes para atualizar essa tarefa."
      render :edit and return
    end

    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to root_path, notice: "Tarefa foi atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_path, status: :see_other, notice: "Tarefa foi removida com sucesso." }
      format.json { head :no_content }
    end
  end

  def mark_completed
    @task.update(status: :completed)
    redirect_to root_path, notice: "Tarefa marcada como concluída."
  end

  def archive
    @task.update(status: :archived)
    redirect_to root_path, notice: "Tarefa arquivada."
  end

  def unarchive
    @task.update(status: :in_progress)
    redirect_to root_path, notice: "Tarefa desarquivada."
  end

  def activities
    task_ids = current_user.commitments.flat_map(&:tasks).pluck(:id)
    @activities = PaperTrail::Version.where(item_type: "Task", item_id: task_ids).order(created_at: :desc)
  end

  private

    def hours_exceed_limit?(new_task_hours, previous_hours = 0)
      total_hours_used = current_user.commitments.where(active: true).flat_map(&:tasks).pluck(:hours).sum - previous_hours
      available_hours = current_user.hours_per_week - total_hours_used

      new_task_hours > available_hours
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description, :category_id, :hours)
    end
end
