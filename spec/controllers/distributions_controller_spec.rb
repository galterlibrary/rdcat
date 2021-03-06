require 'rails_helper'

RSpec.describe DistributionsController, type: :controller do
  before do
    #FIXME
    stub_request(:any, /localhost:9250/)
  end

  let(:dataset)      { FactoryGirl.create(:dataset) }
  let(:distribution) { FactoryGirl.create(:distribution, dataset: dataset) }

  # This should return the minimal set of attributes required to create a valid
  # Distribution. As you add validations to Distribution, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { name: Faker::Name.name, dataset_id: dataset.id }
  }

  let(:invalid_attributes) {
    { name: nil, dataset_id: dataset.id }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DistributionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context 'with a logged in user' do 
    sign_in_user
    let(:dataset) {
      FactoryGirl.create(:dataset, maintainer: controller.current_user)
    }

    before do 
      # TODO: test when user is not associated with the dataset
      dataset.maintainer = controller.current_user
      dataset.save!
    end

    describe 'GET index' do
      it 'assigns all distributions as @distributions' do
        distribution = Distribution.create! valid_attributes
        get :index, params: { dataset_id: dataset.id }, session: valid_session
        expect(assigns(:distributions)).to eq([distribution])
      end
    end

    describe 'GET show' do
      it 'assigns the requested distribution as @distribution' do
        distribution = Distribution.create! valid_attributes
        get :show, params: { dataset_id: dataset.id, id: distribution.to_param }, session: valid_session
        expect(assigns(:distribution)).to eq(distribution)
      end
    end

    describe 'GET new' do
      it 'assigns a new distribution as @distribution' do
        get :new, params: { dataset_id: dataset.id }, session: valid_session
        expect(assigns(:distribution)).to be_a_new(Distribution)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested distribution as @distribution' do
        distribution = Distribution.create! valid_attributes
        get :edit, params: { dataset_id: dataset.id, id: distribution.to_param }, session: valid_session
        expect(assigns(:distribution)).to eq(distribution)
      end
    end

    describe 'GET download' do
      let(:distr) { Distribution.create! valid_attributes }

      subject {
        get(
          :download,
          :params => {
            :dataset_id => distr.dataset.id,
            :id => distr.id
          }
        )
      }

      before do
        expect(Distribution).to receive(:find) { distr }
        expect(distr).to receive(:artifact) {
          double('Uploader', current_path: 'spec/fixtures/artifact1.txt')
        }
      end

      specify do
        expect(subject.body).to eq(IO.binread('spec/fixtures/artifact1.txt'))
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Distribution' do
          expect {
            post :create, params: {
              dataset_id: dataset.id, distribution: valid_attributes
            }, session: valid_session
          }.to change(Distribution, :count).by(1)
        end

        it 'assigns a newly created distribution as @distribution' do
          post :create, params: { dataset_id: dataset.id, distribution: valid_attributes }, session: valid_session
          expect(assigns(:distribution)).to be_a(Distribution)
          expect(assigns(:distribution)).to be_persisted
        end

        it 'redirects to the dataset for the distribution' do
          post :create, params: { dataset_id: dataset.id, distribution: valid_attributes }, session: valid_session
          expect(response).to redirect_to(dataset)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved distribution as @distribution' do
          post :create, params: { dataset_id: dataset.id, distribution: invalid_attributes }, session: valid_session
          expect(assigns(:distribution)).to be_a_new(Distribution)
        end

        it "re-renders the 'new' template" do
          post :create, params: { dataset_id: dataset.id, distribution: invalid_attributes }, session: valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:updated_name) { 'Updated Distribution Name' }
        let(:new_attributes) {
          {name: updated_name}
        }

        it 'updates the requested distribution' do
          put :update, params: { dataset_id: dataset.id, id: distribution.to_param, distribution: new_attributes }, session: valid_session
          distribution.reload
          expect(distribution.name).to eq(updated_name)
        end

        it 'assigns the requested distribution as @distribution' do
          distribution = Distribution.create! valid_attributes
          put :update, params: { dataset_id: dataset.id, id: distribution.to_param, distribution: valid_attributes }, session: valid_session
          expect(assigns(:distribution)).to eq(distribution)
        end

        it 'redirects to the dataset' do
          distribution = Distribution.create! valid_attributes
          put :update, params: { dataset_id: dataset.id, id: distribution.to_param, distribution: valid_attributes }, session: valid_session
          expect(response).to redirect_to(dataset)
        end
      end

      describe 'with invalid params' do
        it 'assigns the distribution as @distribution' do
          distribution = Distribution.create! valid_attributes
          put :update, params: { dataset_id: dataset.id, id: distribution.to_param, distribution: invalid_attributes }, session: valid_session
          expect(assigns(:distribution)).to eq(distribution)
        end

        it "re-renders the 'edit' template" do
          distribution = Distribution.create! valid_attributes
          put :update, params: { dataset_id: dataset.id, id: distribution.to_param, distribution: invalid_attributes }, session: valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested distribution' do
        distribution = Distribution.create! valid_attributes
        expect {
          delete :destroy, params: { dataset_id: dataset.id, id: distribution.to_param }, session: valid_session
        }.to change(Distribution, :count).by(-1)
      end

      it 'redirects to the dataset for the distribution' do
        distribution = Distribution.create! valid_attributes
        delete :destroy, params: { dataset_id: dataset.id, id: distribution.to_param }, session: valid_session
        expect(response).to redirect_to(dataset)
      end
    end
  end
end
