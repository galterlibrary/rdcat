require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    stub_request(:any, /localhost:9250/)
  end
  
  let!(:user_a) { FactoryGirl.create(:user) }
  let!(:user_b) { FactoryGirl.create(:user) }
  
  describe 'index' do
    context 'when not signed in' do
      it 'redirects to sign in' do
        get '/users'
        expect(response).to redirect_to("/users/sign_in")
      end
    end
    
    context 'when signed in' do
      before do
        login_as user_b
      end
      
      it 'displays list of users' do
        get '/users'
        expect(response).to render_template(:index)
        expect(assigns(:users)).to eq([user_a, user_b])
      end
      
      it 'displays appropriate info' do
        visit '/users'
        
        expect(page).to have_content(user_a.name)
        expect(page).to have_content(user_b.name)
        expect(page).to have_content(user_a.username)
        expect(page).to have_content(user_b.username)
        expect(page).to have_content(user_a.email)
        expect(page).to have_content(user_b.email)
        
        expect(page).to have_link("Show", href: user_path(user_a))
        expect(page).to have_link("Show", href: user_path(user_b))
      end
      
    end
  end
  
  describe 'show' do
    context 'when not signed in' do 
      it 'redirects to sign in when not logged in' do
        get '/users/1'
        expect(response).to redirect_to('/users/sign_in')
      end
    end
    
    context 'when signed in as user_a' do
      let!(:dataset_1) { FactoryGirl.create(:dataset, author: user_a, maintainer: user_a) }
      let!(:dataset_2) { FactoryGirl.create(:dataset, author: user_a, maintainer: user_b) }
      let!(:dataset_3) { FactoryGirl.create(:dataset, author: user_b, maintainer: user_a) }
      let!(:dataset_4) { FactoryGirl.create(:dataset, author: user_b, maintainer: user_b) }
      let!(:dataset_zero) { FactoryGirl.create(:dataset) }
      
      before do
        login_as user_a
      end
      
      describe 'viewing self' do
        it 'sets user_a' do
          get user_path(user_a)
          
          expect(response).to render_template(:show)
          expect(assigns(:user)).to eq(user_a)
          expect(assigns(:user_datasets)).to eq([dataset_1, dataset_2, dataset_3])
          expect(assigns(:user_datasets).include?(dataset_4)).to be_falsey
          expect(assigns(:user_datasets).include?(dataset_zero)).to be_falsey
        end
        
        it 'displays appropriate info' do
          visit user_path(user_a)
          
          expect(page).to have_content(user_a.name)
          within('.user_about') do
            expect(page).to have_content("About")
            expect(page).to have_content("Organization: ")
            expect(page).to have_content("Title: ")
            expect(page).to have_content("Email: #{user_a.email}")
          end
          
          within('.user_dataset') do
            expect(page).to have_content("Datasets")
            expect(page).to have_link(dataset_1.title.truncate(30), href: dataset_path(dataset_1))
            expect(page).to have_content("Organization: #{dataset_1.organization.name}")
            expect(page).to have_content("Maintained by: ")
            expect(page).to have_link(dataset_1.maintainer.name, href: user_path(dataset_1.maintainer))
            expect(page).to have_content("Version: #{dataset_1.version}")
            
            expect(page).to have_link(dataset_2.title.truncate(30), href: dataset_path(dataset_2))
            expect(page).to have_content("Organization: #{dataset_2.organization.name}")
            expect(page).to have_link(dataset_2.maintainer.name, href: user_path(dataset_2.maintainer))
            expect(page).to have_content("Version: #{dataset_2.version}")
            
            expect(page).to have_link(dataset_3.title.truncate(30), href: dataset_path(dataset_3))
            expect(page).to have_content("Organization: #{dataset_3.organization.name}")
            expect(page).to have_link(dataset_3.maintainer.name, href: user_path(dataset_3.maintainer))
            expect(page).to have_content("Version: #{dataset_3.version}")
            
            expect(page).to_not have_link(dataset_4.title.truncate(30), href: dataset_path(dataset_4))
            
            expect(page).to_not have_link(dataset_zero.title, href: dataset_path(dataset_zero))
            expect(page).to_not have_link(dataset_zero.maintainer.name, href: user_path(dataset_zero.maintainer))
          end
        end
      end #viewing self
    end
  end #show
end