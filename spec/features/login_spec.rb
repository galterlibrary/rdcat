# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'Logging in', type: :feature do

  before(:each) do 
    Warden.test_mode!
  end

  after(:each) do 
    Warden.test_reset!
  end

  before do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  context 'without having logged in', js: true do
    describe 'visiting the index page' do

      it 'shows the Login link' do 

        visit '/' 

        expect(page).to_not have_content('Logout')
        expect(page).to have_content('Login')
        expect(page).to have_content('Datasets')
        expect(page).to have_content('New Dataset')
      end

    end

    context 'with Dataset data' do 
      let(:description) { Faker::Hipster.sentence }
      before do
        @dataset = FactoryGirl.create(:dataset, description: description)
      end

      describe 'visiting the index page' do

        it 'shows some of the Dataset information' do 

          visit '/' 

          expect(page).to_not have_content(@dataset.description)
          expect(page).to have_content(@dataset.title)
          expect(page).to have_content(@dataset.organization.name)
          expect(page).to have_content(@dataset.maintainer.email)

          expect(page).to have_link('Show')
          # TODO: only show these if the logged in user is the author or maintainer of the dataset
          expect(page).to have_link('Edit')
          expect(page).to have_link('Destroy')
        end

      end



    end

  end

  # context 'entering a netid', js: true do 

  #   before(:each) do
  #     @user = FactoryGirl.create(:user) 
  #     login_as(@user, scope: :user)

  #     stub_request(:get, "https://notis-staging.nubic.northwestern.edu/notis-public/clinical_trials.json?pi_net_id=#{@user.username}").
  #       with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  #       to_return(:status => 200, :body => "", :headers => {})

  #     stub_request(:get, "https://studytracker-staging.fsm.northwestern.edu/api/users/#{@user.username}.json").
  #       with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YnRpX2FwcDp0ZXN0', 'User-Agent'=>'Ruby'}).
  #       to_return(:status => 200, :body => "", :headers => {})
  #   end

  #   it 'renders the index page with results' do 
  #     visit '/profile/'
  #     within "#netid_form" do
  #       fill_in "netid", with: @user.username
  #     end
  #     allow(Ldap.instance).to receive(:find_ldap_entry) {nil}
  #     click_link_or_button 'Process'
  #     expect(page).to have_css('#results')
  #   end

  #   after(:each) do 
  #     @user.destroy
  #   end

  # end

end
