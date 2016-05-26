require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  context 'with a logged in user' do 
    login_user

    describe 'GET index' do 
      it 'renders the page upon requst' do 
        get :index
        expect(response).to render_template('index')
      end
    end
  end

  context 'without a logged in user' do 
    describe 'GET index' do 
      it 'does not render the page' do 
        get :index
        expect(response).to_not render_template('index')
      end
    end
  end

end
