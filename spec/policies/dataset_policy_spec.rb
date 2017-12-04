require 'rails_helper'

describe DatasetPolicy do
  let(:owner) { FactoryGirl.create(:user, admin: false, username: 'abc123') }
  let(:owner2) { FactoryGirl.create(:user, admin: false, username: 'abc124') }
  let(:stranger) { FactoryGirl.create(:user, admin: false, username: 'abc125') }
  let(:admin) { FactoryGirl.create(:user, admin: true) }
  let(:anonymous) { nil }

  subject { described_class }

  before { stub_request(:any, /localhost:9250/) }

  context 'scope' do
    let!(:priv_ds_auth) {
      FactoryGirl.create_list(
        :dataset, 3, author: owner, visibility: 'Private'
      )
    }
    let!(:priv_ds_maint) {
      FactoryGirl.create_list(
        :dataset, 3, maintainer: owner2, visibility: 'Private'
      )
    }
    let!(:public_ds) {
      FactoryGirl.create_list(:dataset, 3, visibility: 'Public')
    }

    describe 'by athor' do
      subject {
          DatasetPolicy::Scope.new(owner, Dataset).resolve
      }

      it "returns author's and public Datasets" do
        expect(subject).to match_array(priv_ds_auth + public_ds)
      end
    end

    describe 'by maintainer' do
      subject {
          DatasetPolicy::Scope.new(owner2, Dataset).resolve
      }

      it "returns maintainer's and public Datasets" do
        expect(subject).to match_array(priv_ds_maint + public_ds)
      end
    end

    describe 'by admin' do
      subject {
          DatasetPolicy::Scope.new(admin, Dataset).resolve
      }

      it "returns all Datasets" do
        expect(subject).to match_array(priv_ds_maint + priv_ds_auth + public_ds)
      end
    end

    describe 'by anonymous' do
      subject {
          DatasetPolicy::Scope.new(anonymous, Dataset).resolve
      }

      it "returns public Datasets" do
        expect(subject).to match_array(public_ds)
      end
    end

    describe 'by stranger' do
      subject {
          DatasetPolicy::Scope.new(stranger, Dataset).resolve
      }

      it "returns public Datasets" do
        expect(subject).to match_array(public_ds)
      end
    end
  end

  permissions :index?, :search?, :new?, :create? do
    context 'Private visibility' do
      let(:record) {
        Dataset.new(visibility: 'Private', author: owner, maintainer: owner)
      }

      it 'grants access to anyone' do
        expect(subject).to permit(stranger, record)
      end
    end

    context 'Public visibility' do
      let(:record) {
        Dataset.new(visibility: 'Public', author: owner, maintainer: owner)
      }

      it 'grants access to anyone' do
        expect(subject).to permit(stranger, record)
      end
    end
  end

  permissions :update?, :edit?, :destroy?, :mint_doi? do
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

      it 'denies access to strangers' do
        expect(subject).not_to permit(stranger, record)
      end

      it 'denies access to anonymous' do
        expect(subject).not_to permit(anonymous, record)
      end
    end
  end

  permissions :show? do
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
