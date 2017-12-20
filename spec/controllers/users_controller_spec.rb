require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    stub_request(:any, /localhost:9250/)
  end
  
  describe 'GET index' do
    context 'without signing in' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to('/users/sign_in')
      end
    end
    
    context 'signed in user' do
      let(:author) { FactoryGirl.create(:user) }
      let(:maintainer) { FactoryGirl.create(:user) }
      
      it 'returns users' do
        sign_in author
        
        get :index
        expect(assigns(:users)).to eq([author, maintainer])
      end
    end
  end
  
  describe 'GET show' do
    let(:author) { FactoryGirl.create(:user) }
    let(:maintainer) { FactoryGirl.create(:user) }
    let(:lone_wolf) { FactoryGirl.create(:user) }
    
    let(:dataset_a) { FactoryGirl.create(:dataset, author: author) }
    let(:dataset_b) { FactoryGirl.create(:dataset, maintainer: author) }
    let(:dataset_c) { FactoryGirl.create(:dataset, author: author, maintainer: maintainer) }
    let(:dataset_d) { FactoryGirl.create(:dataset, maintainer: author, author: maintainer) }
    
    let(:dataset_w) { FactoryGirl.create(:dataset, author: maintainer, visibility: Dataset::PRIVATE) }
    let(:dataset_x) { FactoryGirl.create(:dataset, maintainer: maintainer, visibility: Dataset::PRIVATE) }
    let(:dataset_y) { FactoryGirl.create(:dataset, author: maintainer, maintainer: author, visibility: Dataset::PRIVATE) }
    let(:dataset_z) { FactoryGirl.create(:dataset, maintainer: maintainer, author: author, visibility: Dataset::PRIVATE) }
    
    context 'without signing in' do
      it 'redirects to sign in' do
        get :show, params: {id: author.id}
        expect(response).to redirect_to('/users/sign_in')
      end
    end
    
    context 'signed in user' do
      describe 'viewing self as author' do
        it 'assigns correct profile and correct datasets' do
          sign_in author
          get :show, params: {id: author.id}
          expect(assigns(:user)).to eq(author)
          expect(assigns(:user)).to_not eq(maintainer)
          expect(assigns(:user_datasets)).to eq([dataset_a, dataset_b, dataset_c, dataset_d, dataset_y, dataset_z])
          expect(assigns(:user_datasets).include?(dataset_w)).to be_falsey
          expect(assigns(:user_datasets).count).to eq(6)
        end
      end
      
      describe 'viewing self as maintainer' do
        it 'assigns correct profile and correct datasets' do
          sign_in maintainer
          get :show, params: {id: maintainer.id}
          expect(assigns(:user)).to eq(maintainer)
          expect(assigns(:user)).to_not eq(author)
          expect(assigns(:user_datasets)).to eq([dataset_c, dataset_d, dataset_w, dataset_x, dataset_y, dataset_z])
          expect(assigns(:user_datasets).include?(dataset_a)).to be_falsey
          expect(assigns(:user_datasets).count).to eq(6)
        end
      end
      
      describe 'author viewing maintainer' do
        it 'assigns correct profile and correct datasets' do
          sign_in author
          get :show, params: {id: maintainer.id}
          expect(assigns(:user)).to eq(maintainer)
          expect(assigns(:user)).to_not eq(author)
          expect(assigns(:user_datasets)).to eq([dataset_c, dataset_d, dataset_y, dataset_z])
          expect(assigns(:user_datasets).include?(dataset_w)).to be_falsey
          expect(assigns(:user_datasets).count).to eq(4)
        end
      end
      
      describe 'maintainer viewing author' do
        it 'assigns correct profile and correct datasets' do
          sign_in maintainer
          get :show, params: {id: author.id}
          expect(assigns(:user)).to eq(author)
          expect(assigns(:user)).to_not eq(maintainer)
          expect(assigns(:user_datasets)).to eq([dataset_a, dataset_b, dataset_c, dataset_d, dataset_y, dataset_z])
          expect(assigns(:user_datasets).include?(dataset_w)).to be_falsey
          expect(assigns(:user_datasets).count).to eq(6)
        end
      end
      
      describe 'lone wolf viewing author' do
        it 'assigns correct profile and correct datasets' do
          sign_in lone_wolf
          get :show, params: {id: author.id}
          expect(assigns(:user)).to eq(author)
          expect(assigns(:user_datasets)).to eq([dataset_a, dataset_b, dataset_c, dataset_d])
          expect(assigns(:user_datasets).include?(dataset_z)).to be_falsey
          expect(assigns(:user_datasets).count).to eq(4)
        end
      end
      
      describe 'lone wolf viewing maintainer' do
        it 'assigns correct profile and correct datasets' do
          sign_in lone_wolf
          get :show, params: {id: maintainer.id}
          expect(assigns(:user)).to eq(maintainer)
          expect(assigns(:user_datasets)).to eq([dataset_c, dataset_d])
          expect(assigns(:user_datasets).count).to eq(2)
          expect(assigns(:user_datasets).include?(dataset_w)).to be_falsey
        end
      end
    end
  end

  describe 'PATCH update' do
    let(:user) { FactoryGirl.create(:user) }
    subject { patch :update, params: { id: user.id, user: user_params } }

    before { sign_in user }

    context 'with valid params' do
      let(:user_params) { {
        first_name: 'First', last_name: 'Last', email: 'abc@def.ghi',
        scopusid: 'ABC123', orcid: 'CBA321'
      } }

      specify do
        expect(subject).to redirect_to(@user)
        expect(assigns(:user).first_name).to eq('First')
        expect(assigns(:user).last_name).to eq('Last')
        expect(assigns(:user).email).to eq('abc@def.ghi')
        expect(assigns(:user).scopusid).to eq('ABC123')
        expect(assigns(:user).orcid).to eq('CBA321')
        expect(flash.notice).to eq('User was successfully updated.')
      end
    end

    context 'with invalid params' do
      let(:user_params) { {
        first_name: 'First', last_name: 'Last', email: '',
        scopusid: 'ABC123', orcid: 'CBA321'
      } }

      specify do
        expect(subject).to render_template('edit')
      end
    end
  end
end
