require 'rails_helper'

RSpec.describe DatasetsController, type: :controller do
  before do
    stub_request(:any, /localhost:9250/)
  end

  let(:org) { FactoryGirl.create(:organization) }
  let(:usr) { FactoryGirl.create(:user) }

  # This should return the minimal set of attributes required to create a valid
  # Dataset. As you add validations to Dataset, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {
    title: 'DS Title', description: 'description',
    author_id: usr.id, maintainer_id: usr.id, visibility: Dataset::PUBLIC,
    state: Dataset::ACTIVE
  } }

  let(:invalid_attributes) { {
    title: nil, description: 'description',
    author_id: usr.id, maintainer_id: usr.id
  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DatasetsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'uses Dataset policy scope' do
      expect(controller).to receive(:policy_scope)
                        .with(Dataset)
                        .exactly(2).times
                        .and_call_original
      ds = double(Dataset, order: [])
      expect(controller).to receive(:policy_scope).with(Dataset) { ds }
      expect(ds).to receive(:order).with('updated_at DESC')
      get :index, params: {}, session: valid_session
    end
  end

  describe 'GET search' do
    it 'returns results for anonymous user' do
      expect(Dataset).to receive(:search).with('the term', current_netid: nil) {
        double('elasticsearch-results', records: [1,2,3])
      }
      get :search, params: {q: 'the term'}
      expect(assigns(:datasets)).to eq([1,2,3])
    end
  end

  context 'with a logged in user' do 
    sign_in_user

    describe 'GET index' do
      it 'assigns all datasets as @datasets' do
        dataset = Dataset.create! valid_attributes
        get :index, params: {}, session: valid_session
        expect(assigns(:datasets)).to eq([dataset])
      end
    end

    describe 'GET show' do
      it 'assigns the requested dataset as @dataset' do
        dataset = Dataset.create! valid_attributes
        get :show, params: {id: dataset.to_param}, session: valid_session
        expect(assigns(:dataset)).to eq(dataset)
      end
    end

    describe 'GET search' do
      it 'returns results for authenticated user' do
        expect(Dataset).to receive(:search).with(
          'the term', current_netid: controller.current_user.username
        ) { double('elasticsearch-results', records: [1,2,3]) }
        get :search, params: {q: 'the term'}, session: valid_session
        expect(assigns(:datasets)).to eq([1,2,3])
      end
    end

    describe 'GET new' do
      it 'assigns a new dataset as @dataset' do
        get :new, params: {}, session: valid_session
        expect(assigns(:dataset)).to be_a_new(Dataset)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested dataset as @dataset' do
        dataset = Dataset.create! valid_attributes
        get :edit, params: {id: dataset.to_param}, session: valid_session
        expect(assigns(:dataset)).to eq(dataset)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Dataset' do
          expect {
            post :create, params: {dataset: valid_attributes}, session: valid_session
          }.to change(Dataset, :count).by(1)
        end

        it 'assigns a newly created dataset as @dataset' do
          post :create, params: {dataset: valid_attributes}, session: valid_session
          expect(assigns(:dataset)).to be_a(Dataset)
          expect(assigns(:dataset)).to be_persisted
        end

        it 'redirects to the datasets index' do
          post :create, params: {dataset: valid_attributes}, session: valid_session
          expect(response).to redirect_to(dataset_path(Dataset.last))
        end
      end

      describe 'with invalid params' do
        specify do
          expect(controller).to receive(:set_categories).and_call_original
          expect(controller).to receive(:set_licenses).and_call_original
          post :create, params: {dataset: invalid_attributes},
                        session: valid_session
          expect(assigns(:dataset)).to be_a_new(Dataset)
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:updated_title) { 'Updated DS Title' }
        let(:new_attributes) {
          { title: updated_title, 
            description: 'Updated description', 
            author_id: usr.id, 
            maintainer_id: controller.current_user.id }
        }

        it 'updates the requested dataset and redirects' do
          dataset = FactoryGirl.create(
            :dataset, maintainer: controller.current_user
          )
          expect_any_instance_of(Dataset).not_to receive(:update_or_create_doi)
          put :update,
              :params => {id: dataset.to_param, dataset: new_attributes},
              :session => valid_session
          dataset.reload
          expect(dataset.title).to eq(updated_title)
          expect(assigns(:dataset)).to eq(dataset)
          expect(response).to redirect_to([dataset])
        end

        context 'with a DOI, returning :notice' do
          let(:dataset) {
            FactoryGirl.create(
              :dataset, maintainer: controller.current_user, doi: 'ABC'
            )
          }

          before do
            expect(controller).to receive(:set_dataset) {
              controller.instance_variable_set(:@dataset, dataset)
            }
          end

          it 'updates the DOI and appends to :notice' do
            expect(dataset).to receive(:update_or_create_doi) {
              dataset.doi_status = :notice
              dataset.doi_message = "Hello world"
            }

            put :update,
                :params => {id: dataset.to_param, dataset: new_attributes},
                :session => valid_session
            expect(flash[:notice]).to eq(
              'Dataset was successfully updated. Hello world'
            )
          end
        end

        context 'with a DOI, returning something other then :notice' do
          let(:dataset) {
            FactoryGirl.create(
              :dataset, maintainer: controller.current_user, doi: 'ABC'
            )
          }

          before do
            expect(controller).to receive(:set_dataset) {
              controller.instance_variable_set(:@dataset, dataset)
            }
          end

          it 'updates the DOI and flashes' do
            expect(dataset).to receive(:update_or_create_doi) {
              dataset.doi_status = :alert
              dataset.doi_message = "Hello world"
            }

            put :update,
                :params => {id: dataset.to_param, dataset: new_attributes},
                :session => valid_session
            expect(flash[:notice]).to eq('Dataset was successfully updated.')
            expect(flash[:alert]).to eq('Hello world')
          end
        end
      end

      describe 'with invalid params' do
        it 'assigns the dataset as @dataset and renders edit' do
          dataset = FactoryGirl.create(
            :dataset, maintainer: controller.current_user
          )
          expect_any_instance_of(Dataset).not_to receive(:update_or_create_doi)
          expect(controller).to receive(:set_categories).and_call_original
          expect(controller).to receive(:set_licenses).and_call_original
          put :update,
              :params => {id: dataset.to_param, dataset: invalid_attributes},
              :session => valid_session
          expect(assigns(:dataset)).to eq(dataset)
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'POST mint_doi' do
      subject {
        post :mint_doi, params: {id: dataset.to_param}, session: valid_session
      }

      describe 'when DOI already exists' do
        let(:dataset) { FactoryGirl.create(
          :dataset, doi: 'ABC', maintainer: controller.current_user
        ) }

        it 'redirects back without minting' do
          expect(subject).to redirect_to(dataset_path(dataset))
          expect(flash[:alert]).to include('DOI already exists')
        end
      end

      describe 'when DOI does not exist' do
        let(:dataset) { FactoryGirl.create(
          :dataset, doi: nil, maintainer: controller.current_user
        ) }

        before do
          expect(controller).to receive(:set_dataset) {
            controller.instance_variable_set(:@dataset, dataset)
          }
        end

        it 'mints a DOI and redirects' do
          expect(dataset).to receive(:update_or_create_doi) {
            dataset.doi_status = :notice
            dataset.doi_message = 'hello pollo'
            nil
          }
          expect(subject).to redirect_to(dataset_path(dataset))
          expect(flash[:notice]).to include('hello pollo')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested dataset' do
        dataset = FactoryGirl.create(
          :dataset, maintainer: controller.current_user
        )
        expect_any_instance_of(Dataset).not_to receive(:deactivate_or_remove_doi)
        expect {
          delete :destroy,
                 :params => {id: dataset.to_param},
                 :session => valid_session
        }.to change(Dataset, :count).by(-1)
        expect(response).to redirect_to(datasets_url)
      end

      context 'with a DOI' do
        it 'handles DOI removal' do
          dataset = FactoryGirl.create(
            :dataset, maintainer: controller.current_user, doi: 'SOMETHING'
          )
          expect_any_instance_of(Dataset).to receive(:deactivate_or_remove_doi)
          expect {
            delete :destroy,
                   :params => {id: dataset.to_param},
                   :session => valid_session
          }.to change(Dataset, :count).by(-1)
          expect(response).to redirect_to(datasets_url)
        end
      end
    end
  end
end
