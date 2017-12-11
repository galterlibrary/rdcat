require 'rails_helper'

describe UserPolicy do
  let(:stranger) { FactoryGirl.create(:user, admin: false, username: 'abc125') }
  let(:user) { FactoryGirl.create(:user, admin: false, username: 'abc123') }
  let(:admin) { FactoryGirl.create(:user, admin: true) }
  let(:anonymous) { nil }

  subject { described_class }

  before { stub_request(:any, /localhost:9250/) }

  permissions :index?, :new?, :show? do
    it 'grants access to anyone' do
      expect(subject).to permit(stranger, user)
    end
  end

  permissions :create?, :update?, :edit?, :destroy? do
    it 'grants access to admins' do
      expect(subject).to permit(admin, user)
    end

    it 'grants access to self' do
      expect(subject).to permit(user, user)
    end

    it 'denies access to stranger' do
      expect(subject).not_to permit(stranger, user)
    end

    it 'denies access to anonymous' do
      expect(subject).not_to permit(anonymous, user)
    end
  end
end
