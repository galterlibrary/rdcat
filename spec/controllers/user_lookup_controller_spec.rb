require 'rails_helper'

RSpec.describe UserLookupController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, admin: true) }
  let(:user) { FactoryGirl.create(:user, username: 'asdf') }
    
  before do
    stub_request(:any, /localhost:9250/)
  end
  
  describe 'POST ldap' do
    context 'without signing in' do
      it 'redirects to sign in' do
        post :ldap, params: { netid: 'asdf' }
        expect(response).to redirect_to('/users/sign_in')
      end
    end
    
    context 'creating new user works' do
      describe 'authorized to edit user' do
        before do
          sign_in admin
          expect(User).to receive(:find_or_create_by_username).with('asdf') {
            user
          }
        end

        it 'creates user and redirects to edit' do
          expect {
            post :ldap, params: { netid: 'asdf' }
          }.to change { User.count }.by(1)
          expect(response).to redirect_to("/users/#{user.id}/edit")
        end
      end

      describe 'unauthorized to edit user' do
        before do
          sign_in FactoryGirl.create(:user)
          expect(User).to receive(:find_or_create_by_username).with('asdf') {
            user
          }
        end

        it 'creates user and redirects to edit' do
          expect {
            post :ldap, params: { netid: 'asdf' }
          }.to change { User.count }.by(1)
          expect(flash.notice).to include("User `asdf` created")
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'creating new user does not works' do
      before do
        sign_in FactoryGirl.create(:user)
        expect(User).to receive(:find_or_create_by_username).with('asdf') {
          false
        }
      end

      it 'creates user and redirects to edit' do
        expect {
          post :ldap, params: { netid: 'asdf' }
        }.not_to change { User.count }
        expect(flash.alert).to include('No user found with username')
        expect(response).to redirect_to('/users/new')
      end
    end
  end
end
