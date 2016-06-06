class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :edit]

  before_action :clean_select_multiple_params, only: [:create, :update]

  # GET /datasets
  # GET /datasets.json
  def index
    @datasets = Dataset.all
  end

  # GET /datasets/1
  # GET /datasets/1.json
  def show
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets
  # POST /datasets.json
  def create
    @dataset = Dataset.new(dataset_params)

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to datasets_path, notice: 'Dataset was successfully created.' }
        format.json { render :show, status: :created, location: @dataset }
      else
        format.html { render :new }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datasets/1
  # PATCH/PUT /datasets/1.json
  def update
    respond_to do |format|
      if @dataset.update(dataset_params)
        format.html { redirect_to datasets_path, notice: 'Dataset was successfully updated.' }
        format.json { render :show, status: :ok, location: @dataset }
      else
        format.html { render :edit }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.json
  def destroy
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url, notice: 'Dataset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      @dataset = Dataset.find(params[:id])
    end

    def set_categories
      @categories = Category.pluck(:name).sort
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.fetch(:dataset, {}).permit(:title, 
                                        :description, 
                                        :license, 
                                        :organization_id,
                                        :visibility, 
                                        :state,
                                        :source,
                                        :version,
                                        :author_id,
                                        :maintainer_id,
                                        { categories: [] })
    end

    # Used to strip blank first values from array-type params.
    def clean_select_multiple_params(hash = params)
      hash.each do |key, value|
        case value
        when Array then value.reject!(&:blank?)
        when Hash then clean_select_multiple_params(value)
        end
      end
    end
end
