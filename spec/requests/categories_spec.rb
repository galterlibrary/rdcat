require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  describe 'GET /categories' do
    context 'with a logged in admin user' do 
      it 'responds with success (200)' do
        admin = FactoryGirl.create(:admin)
        login_as admin
        get categories_path
        expect(response).to have_http_status(200)
      end
    end

    context 'with a logged in user' do 
      it 'responds with redirect (302)' do
        user = FactoryGirl.create(:user)
        login_as user
        get categories_path
        expect(response).to have_http_status(302)
      end
    end
  end
end
