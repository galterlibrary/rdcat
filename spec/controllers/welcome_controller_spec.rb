require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  context 'with a logged in user' do 
    sign_in_user

    describe 'GET index' do 
      it 'renders the page upon requst' do 
        get :index
        expect(response).to render_template('index')
      end
    end
  end

  context 'without a logged in user' do 
    describe 'GET index' do 
      it 'renders the page upon requst' do
        get :index
        expect(response).to render_template('index')
      end
    end
  end
  
  context 'without categories' do
    it 'does not have any categories' do
      get :index
      expect(assigns(:categories)).to eq([])
    end
  end
    
  context 'with categories' do
    before do
      stub_request(:any, /localhost:9250/)
    end
    
    let(:org) { FactoryGirl.create(:organization) }
    let(:usr) { FactoryGirl.create(:user) }
    let(:valid_attributes) {
      { title: 'DS Title', description: 'description', 
        organization_id: org.id, author_id: usr.id, maintainer_id: usr.id, 
        visibility: Dataset::PUBLIC, state: Dataset::ACTIVE, categories: [Faker::Name.name]
      }
    }

    it 'has one category' do
      dataset = Dataset.create! valid_attributes
      get :index
      expect(assigns(:categories)).to eq(dataset.categories)
    end
  end

end
