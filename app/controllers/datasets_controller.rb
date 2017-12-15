class DatasetsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index, :search]
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :mint_doi]
  before_action :set_licenses, only: [:new, :edit]

  before_action :clean_select_multiple_params, only: [:create, :update]

  after_action :update_doi, only: [:update]
  after_action :remove_doi, only: [:destroy]

  # GET /datasets
  # GET /datasets.json
  def index
    @categories = policy_scope(Dataset).chosen_categories
    @organizations = policy_scope(Dataset).known_organizations
    @datasets = policy_scope(Dataset).order('updated_at DESC')

    if params[:category] 
      @datasets = @datasets.where("? = ANY (categories)", params[:category])
    end

    if params[:organization_id]
      @datasets = @datasets.joins(:dataset_organizations).where(
        'dataset_organizations.organization_id = ?', params[:organization_id]
      )
    end
    
    if params[:fast_category]
      @datasets = @datasets.where(
        "? = ANY (fast_categories)", params[:fast_category]
      )
    end
  end

  def search
    return redirect_to datasets_path if params[:q].blank?

    @categories = Dataset.chosen_categories
    @organizations = Dataset.known_organizations
    @datasets = Dataset.search(
      params[:q],
      current_netid: current_user.try(:username)
    ).records
  end

  # GET /datasets/1
  # GET /datasets/1.json
  def show
    authorize @dataset
    redirect_to datasets_path if params[:id] == 'search' 
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1/edit
  def edit
    authorize @dataset
  end

  # POST /datasets
  # POST /datasets.json
  def create
    @dataset = Dataset.new(dataset_params)

    respond_to do |format|
      if @dataset.save
        update_orgs
        write_json_to_file(@dataset)
        
        format.html {
          redirect_to @dataset, notice: 'Dataset was successfully created.'
        }
        format.json { render :show, status: :created, location: @dataset }
      else
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
        format.html {
          set_licenses
          render :new
        }
      end
    end
  end

  # PATCH/PUT /datasets/1
  # PATCH/PUT /datasets/1.json
  def update
    authorize @dataset
    respond_to do |format|
      if @dataset.update(dataset_params)
        update_orgs
        write_json_to_file(@dataset)
        format.html {
          redirect_to @dataset,
                      notice: 'Dataset was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @dataset }
      else
        format.html {
          set_licenses
          render :edit
        }
        format.json {
          render json: @dataset.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.json
  def destroy
    authorize @dataset
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url, notice: 'Dataset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def mint_doi
    authorize @dataset
    if @dataset.doi.blank?
      @dataset.update_or_create_doi
      flash[@dataset.doi_status] = @dataset.doi_message
    else
      flash[:alert] = 'DOI already exists for the dataset.'
    end
    redirect_to @dataset
  end

  private
    def update_orgs
      return if params[:dataset][:dataset_organizations].blank?
      new_oids = params[:dataset][:dataset_organizations].to_unsafe_h
                                                         .values
                                                         .flatten
                                                         .reject(&:blank?)
      current_oids = @dataset.dataset_organizations.pluck(:organization_id)
      (current_oids - new_oids).each do |oid|
        @dataset.dataset_organizations.find_by(organization_id: oid).delete
      end
      (new_oids - current_oids).each do |oid|
        @dataset.dataset_organizations.create(organization_id: oid)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      @dataset = Dataset.find(params[:id]) unless params[:id] == 'search'
    end

    def set_licenses
      @licenses = License.pluck(:title).sort
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.fetch(:dataset, {}).permit(:title, 
                                        :description, 
                                        :grants_and_funding,
                                        :license, 
                                        :characteristic_id,
                                        :visibility, 
                                        :state,
                                        :source,
                                        :version,
                                        :author_id,
                                        :maintainer_id,
                                        { categories: [], fast_categories: [] })
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

    def write_json_to_file(dataset)
      without_html_escaping_in_json do 
        json_str = render_to_string(
          template: 'datasets/show.json.jbuilder', locals: { dataset: dataset }
        )
        filename = "output/datasets/#{dataset.id}.json"
        File.open(filename, 'w') { |file| file.write(json_str) }
      end
    end

    def without_html_escaping_in_json(&block)
      ActiveSupport.escape_html_entities_in_json = false
      result = yield
      ActiveSupport.escape_html_entities_in_json = true
      result
    end

    def update_doi
      if @dataset.doi.present? && @dataset.errors.blank?
        @dataset.reload.update_or_create_doi
        if flash[@dataset.doi_status].blank?
          flash[@dataset.doi_status] = @dataset.doi_message
        else
          flash[@dataset.doi_status] += " #{@dataset.doi_message}"
        end
      end
    end

    def remove_doi
      if @dataset.doi.present?
        @dataset.deactivate_or_remove_doi
      end
    end
end
