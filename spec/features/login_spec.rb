# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'Logging in', type: :feature do

  before(:each) do 
    Warden.test_mode!
    stub_request(:any, /localhost:9250/)
  end

  after(:each) do 
    Warden.test_reset!
  end

  before do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end
  
  describe 'signing in' do
    let(:user) { FactoryGirl.create(:user) }
    
    it 'should sign in user', js: true do
      visit new_user_session_path
      fill_in 'Username', with: user.username
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(page).to have_content "Signed in successfully"
      click_button 'flash_close'
      expect(page).to_not have_content "Signed in successfully"
    end
  end

  context 'without having logged in', js: true do

    describe 'visting the root page' do 
      it 'describes the application' do 
        visit '/'

        expect(page).to have_link('Home', href: '/')
        expect(page).to have_link('About', href: '/about')
        expect(page).to have_link('Giving', href: '#')
        expect(page).to have_content('Login')
        expect(page).to have_content('Galter DataCat')
        expect(page).to have_selector("input[placeholder='Enter your search query here']")
      end
    end

    describe 'visiting the dataset index page' do

      it 'shows the Login link' do 

        visit datasets_path

        expect(page).to_not have_content('Logout')
        expect(page).to have_content('Login')
        expect(page).to have_content('Galter DataCat')
      end

    end

    context 'with Dataset data' do 
      let(:description) { Faker::Hipster.sentence }
      before do
        @dataset = FactoryGirl.create(:dataset, description: description)
      end

      describe 'visiting the dataset index page' do

        it 'shows some of the Dataset information' do 

          visit datasets_path

          expect(page).to have_content(@dataset.description)
          expect(page).to have_link("#{@dataset.title} - #{@dataset.author.name}")
          expect(page).to have_content(@dataset.organization.name)
          expect(page).to have_content(@dataset.maintainer.email)
        end

      end

    end

  end

  context 'having logged in', js: true do

    before(:each) do
      @user = FactoryGirl.create(:user) 
      login_as(@user, scope: :user)
    end

    describe 'visiting the dataset index page' do

      it 'shows the Logout link' do 

        visit datasets_path

        expect(page).to have_link('Logout')
        expect(page).to have_link(@user.name, href: "/users/#{@user.id}")
        expect(page).to_not have_content('Login')
      end

    end

    context 'with Dataset data' do 
      let(:description) { Faker::Hipster.sentence }
      before do
        @dataset = FactoryGirl.create(:dataset, description: description)
      end

      describe 'visiting the dataset index page' do

        it 'shows links for logged in users' do 

          visit datasets_path

          within('.top-bar-right.no-bullet') do
            expect(page).to have_css('a#plus_tip[href="/datasets/new"]')
            expect(page).to have_css('i.fi-plus')
          end

          expect(page).to_not have_link('Edit')
          expect(page).to_not have_link('Destroy')
        end

      end
    end

    context 'with Dataset data maintained by the logged in user' do 
      let(:description) { Faker::Hipster.sentence }
      before do
        @dataset = FactoryGirl.create(:dataset, description: description, maintainer: @user)
      end

      describe 'visiting the dataset index page' do

        it 'shows links for logged in users' do 

          visit datasets_path

          expect(page).to have_link('Edit')
          expect(page).to_not have_link('Destroy')
        end

      end
    end

  end

end
