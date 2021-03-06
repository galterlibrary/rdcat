require 'rails_helper'

describe DistributionPolicy do
  let(:owner) { User.new(admin: false, username: 'abc123') }
  let(:stranger) { User.new(admin: false, username: 'abc123') }
  let(:admin) { User.new(admin: true) }
  let(:anonymous) { nil }
  subject { described_class }

  permissions :index? do
    let(:record) { FactoryGirl.build(:distribution, dataset: ds) }

    context 'Private visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Private', author: owner, maintainer: owner
        )
      }

      it 'grants access to admins' do
        expect(subject).to permit(admin, record)
      end

      it 'grants access to owner' do
        expect(subject).to permit(owner, record)
      end

      it 'denies access to stranger' do
        expect(subject).not_to permit(stranger, record)
      end

      it 'denies access to anonymous' do
        expect(subject).not_to permit(anonymous, record)
      end
    end

    context 'Public visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Public', author: owner, maintainer: owner
        )
      }

      it 'grants access to strangers' do
        expect(subject).to permit(stranger, record)
      end

      it 'grants access to anonymous' do
        expect(subject).to permit(anonymous, record)
      end
    end
  end
  
  permissions :new?, :create?, :update?, :edit?, :destroy? do
    let(:record) { FactoryGirl.build(:distribution, dataset: ds) }

    context 'Private visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Private', author: owner, maintainer: owner
        )
      }

      it 'grants access to admins' do
        expect(subject).to permit(admin, record)
      end

      it 'grants access to owner' do
        expect(subject).to permit(owner, record)
      end

      it 'denies access to stranger' do
        expect(subject).not_to permit(stranger, record)
      end

      it 'denies access to anonymous' do
        expect(subject).not_to permit(anonymous, record)
      end
    end

    context 'Public visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Public', author: owner, maintainer: owner
        )
      }

      it 'denies access to strangers' do
        expect(subject).not_to permit(stranger, record)
      end

      it 'denies access to anonymous' do
        expect(subject).not_to permit(anonymous, record)
      end
    end
  end

  permissions :show?, :download? do
    let(:record) { FactoryGirl.build(:distribution, dataset: ds) }

    context 'Private visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Private', author: owner, maintainer: owner
        )
      }

      it 'grants access to admins' do
        expect(subject).to permit(admin, record)
      end

      it 'grants access to owner' do
        expect(subject).to permit(owner, record)
      end

      it 'denies access to stranger' do
        expect(subject).not_to permit(stranger, record)
      end

      it 'denies access to anonymous' do
        expect(subject).not_to permit(anonymous, record)
      end
    end

    context 'Public visibility' do
      let(:ds) {
        FactoryGirl.build(
          :dataset, visibility: 'Public', author: owner, maintainer: owner
        )
      }

      it 'grants access to strangers' do
        expect(subject).to permit(stranger, record)
      end

      it 'grants access to anonymous' do
        expect(subject).to permit(anonymous, record)
      end
    end
  end
end
