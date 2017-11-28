require 'rails_helper'

describe DatasetPolicy do
  subject { described_class }

  permissions :show? do
    let(:owner) { User.new(admin: false, username: 'abc123') }
    let(:stranger) { User.new(admin: false, username: 'abc123') }
    let(:admin) { User.new(admin: true) }
    let(:anonymous) { nil }

    context 'Private visibility' do
      let(:record) {
        Dataset.new(visibility: 'Private', author: owner, maintainer: owner)
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
      let(:record) {
        Dataset.new(visibility: 'Public', author: owner, maintainer: owner)
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
