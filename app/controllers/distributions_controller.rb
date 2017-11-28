class DistributionsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_dataset
  before_action :set_distribution, only: [:show, :edit, :update, :destroy]

  # GET /datasets/:dataset_id/distributions
  # GET /datasets/:dataset_id/distributions.json
  def index
    @distributions = Distribution.all
  end

  # GET /datasets/:dataset_id/distributions/1
  # GET /datasets/:dataset_id/distributions/1.json
  def show
  end

  # GET /datasets/:dataset_id/distributions/new
  def new
    @distribution = Distribution.new
  end

  # GET /datasets/:dataset_id/distributions/1/edit
  def edit
    authorize @distribution
  end

  # POST /datasets/:dataset_id/distributions
  # POST /datasets/:dataset_id/distributions.json
  def create
    @distribution = Distribution.new(distribution_params)
    @distribution.dataset = @dataset

    respond_to do |format|
      if @distribution.save
        format.html { redirect_to @dataset, notice: 'Distribution was successfully created.' }
        format.json { render :show, status: :created, location: @distribution }
      else
        format.html { render :new }
        format.json { render json: @distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datasets/:dataset_id/distributions/1
  # PATCH/PUT /datasets/:dataset_id/distributions/1.json
  def update
    authorize @distribution
    respond_to do |format|
      if @distribution.update(distribution_params)
        format.html { redirect_to @dataset, notice: 'Distribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @distribution }
      else
        format.html { render :edit }
        format.json { render json: @distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/:dataset_id//distributions/1
  # DELETE /datasets/:dataset_id//distributions/1.json
  def destroy
    authorize @distribution
    @distribution.destroy
    respond_to do |format|
      format.html { redirect_to @dataset, notice: 'Distribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /datasets/:dataset_id/distributions/:id/download
  def download
    @document = Dataset.find(params[:dataset_id]).distributions.find(params[:id])
    send_file @document.artifact.current_path
  end

  private
    def set_dataset
      @dataset = Dataset.find(params[:dataset_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_distribution
      @distribution = Distribution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def distribution_params
      params.fetch(:distribution, {}).permit(:dataset_id,
                                             :uri,
                                             :name,
                                             :description,
                                             :artifact,
                                             :format)
    end
end
