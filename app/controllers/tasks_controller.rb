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
    
    @task.commitment = current_user.commitments.find_by(active: true)

    total_hours_used = current_user.commitments.flat_map(&:tasks).pluck(:hours).sum || 0
    available_hours = current_user.hours_per_week - total_hours_used

    if @task.hours > available_hours
      flash[:alert] = "Você não tem horas livres suficientes para cadastrar essa tarefa."
      render :new and return
    elsif @task.hours <= 0
      flash[:alert] = "A tarefa deve ter horas positivas."
      render :new and return
    end

    respond_to do |format|
      if @task.save
        TaskHistory.create(task: @task, commitment: @task.commitment)
        format.html { redirect_to root_path, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to root_path, notice: "Task was successfully updated." }
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
      format.html { redirect_to tasks_path, status: :see_other, notice: "Task was successfully destroyed." }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description, :category_id, :hours)
    end
end
