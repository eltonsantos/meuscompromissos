class CommitmentsController < ApplicationController
  before_action :set_commitment, only: %i[ show edit update destroy ]

  # GET /commitments or /commitments.json
  def index
    @commitments = Commitment.where(user_id: current_user.id)
  end

  # GET /commitments/1 or /commitments/1.json
  def show
  end

  # GET /commitments/new
  def new
    @commitment = Commitment.new
    # @previous_tasks = Task.where(status: 0, commitment: current_user.commitments.last)
  end

  # GET /commitments/1/edit
  def edit
  end

  # POST /commitments or /commitments.json
  def create

    if current_user.commitments.where(active: true).exists?
      flash[:alert] = "Você já tem um compromisso ativo. É permitido apenas um compromisso ativo por vez."
      render :new and return
    end
    
    @commitment = Commitment.new(commitment_params)
    @commitment.user = current_user
    @commitment.active = true

    respond_to do |format|
      if @commitment.save
        format.html { redirect_to root_path, notice: "Compromisso foi criado com sucesso." }
        format.json { render :show, status: :created, location: @commitment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @commitment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commitments/1 or /commitments/1.json
  def update
    respond_to do |format|
      if @commitment.update(commitment_params)
        format.html { redirect_to root_path, notice: "Compromisso foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @commitment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @commitment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commitments/1 or /commitments/1.json
  def destroy
    @commitment.destroy!

    respond_to do |format|
      format.html { redirect_to commitments_path, status: :see_other, notice: "Compromisso foi removido com sucesso." }
      format.json { head :no_content }
    end
  end

  def previous
    @previous_commitments = current_user.commitments.where(active: false).where('created_at <= ?', 7.days.ago).includes(:tasks).order(created_at: :desc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commitment
      @commitment = Commitment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def commitment_params
      params.require(:commitment).permit(:description, :progress)
    end
end
