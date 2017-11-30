require 'rails_helper'

RSpec.describe Dataset, :type => :model do
  before do
    stub_request(:any, /localhost:9250/)
  end

  describe '#ezid_metadata' do
    let(:maintainer) { FactoryGirl.create(:user) }
    let(:author) { FactoryGirl.create(:user) }

    subject { ds.send(:ezid_metadata, 'some status') }

    context 'no author' do
      let(:ds) {
        FactoryGirl.create(
          :dataset, maintainer: maintainer, author: nil
        )
      }

      specify do
        ds.created_at = Date.new(2016)
        expect(subject.class).to eq(Ezid::Metadata)
        expect(subject['datacite.creator']).to eq(maintainer.name)
        expect(subject['datacite.title']).to eq(ds.title)
        expect(subject['datacite.publisher']).to eq(
          'Galter Health Science Library')
        expect(subject['datacite.publicationyear']).to eq('2016')
        expect(subject['_status']).to eq('some status')
        expect(subject['_target']).to eq(
          "#{ENV['PRODUCTION_URL']}/datasets/#{ds.id}"
        )
      end
    end

    context 'author present' do
      let(:ds) {
        FactoryGirl.create(
          :dataset, maintainer: maintainer, author: author
        )
      }

      specify do
        ds.created_at = Date.new(2016)
        expect(subject.class).to eq(Ezid::Metadata)
        expect(subject['datacite.creator']).to eq(author.name)
        expect(subject['datacite.title']).to eq(ds.title)
        expect(subject['datacite.publisher']).to eq(
          'Galter Health Science Library')
        expect(subject['datacite.publicationyear']).to eq('2016')
        expect(subject['_status']).to eq('some status')
        expect(subject['_target']).to eq(
          "#{ENV['PRODUCTION_URL']}/datasets/#{ds.id}"
        )
      end
    end
  end

  describe '#update_doi_metadata_message' do
    subject {
      ds = Dataset.new
      ds.send(:update_doi_metadata_message, identifier, new_status)
      ds
    }

    context 'new status is unavailable' do
      let(:new_status) { 'unavailable' }

      describe 'no status change' do
        let(:identifier) { double(Ezid, status: 'unavailable') }

        it "doesn't warn" do
          expect(subject.doi_status).not_to eq(:warn)
        end
      end

      describe 'status changed' do
        let(:identifier) { double(Ezid, status: 'public') }

        it "doesn't warn" do
          expect(subject.doi_status).to eq(:warn)
        end
      end
    end

    context 'new status is not unavailable' do
      let(:new_status) { 'something else' }
      let(:identifier) { double(Ezid, status: 'unavailable') }

      it "doesn't warn" do
        expect(subject.doi_status).not_to eq(:warn)
      end
    end
  end

  describe '#update_doi_metadata' do
    subject {
      ds.send(:update_doi_metadata)
      ds
    }

    context 'no DOI to update' do
      let(:ds) { Dataset.new(doi: nil) }
      
      specify do
        expect(Ezid::Identifier).not_to receive(:find)
        expect(subject.doi_status).to be_blank
      end
    end

    context 'error finding DOI' do
      let(:ds) { Dataset.new(doi: 'bad') }

      before do
        expect(Ezid::Identifier).to receive(:find) {
          raise Ezid::Error
        }
      end
      
      specify do
        expect(subject.doi_status).to eq(:error)
      end
    end

    context 'valid DOI' do
      let(:ds) { Dataset.new(doi: ' good ', visibility: Dataset::PUBLIC) }
      let(:identifier) {
        double(Ezid::Identifier, update_metadata: true, save: true)
      }

      before do
        expect(Ezid::Identifier).to receive(:find).with('good') {
          identifier
        }
      end
      
      specify do
        expect(ds).to receive(:update_doi_metadata_message).with(
          identifier, 'public'
        )
        expect(ds).to receive(:ezid_metadata).with('public') { 'META' }
        expect(identifier).to receive(:update_metadata).with('META')
        expect(identifier).to receive(:save)
        expect(subject.doi_status).to be_nil
      end
    end
  end

  describe '#create_doi' do
    let(:identifier) {
      double(Ezid::Identifier, status: id_status, id: 'ABC123')
    }

    subject {
      ds.send(:create_doi)
      ds
    }

    context 'public dataset' do
      let(:ds) { Dataset.new(visibility: Dataset::PUBLIC) }
      let(:id_status) { 'public' }

      specify do
        expect(ds).to receive(:ezid_metadata).with('public') { 'META' }
        expect(Ezid::Identifier).to receive(:mint).with('META') {
          identifier
        }
        expect(ds).to receive(:update_attributes).with(doi: 'ABC123')
        expect(subject.doi_status).to be_nil
        expect(subject.doi_message).to include('DOI was generated')
      end
    end

    context 'public dataset' do
      let(:ds) { Dataset.new(visibility: Dataset::PRIVATE) }
      let(:id_status) { 'reserved' }

      specify do
        expect(ds).to receive(:ezid_metadata).with('reserved') { 'META' }
        expect(Ezid::Identifier).to receive(:mint).with('META') {
          identifier
        }
        expect(ds).to receive(:update_attributes).with(doi: 'ABC123')
        expect(subject.doi_status).to eq(:warn)
        expect(subject.doi_message).to include(
          'DOI was generated. Because your document lacks permission'
        )
      end
    end
  end

  describe '#can_get_doi?' do
    subject { ds.send(:can_get_doi?) }

    context 'some properties missing' do
      let(:ds) { Dataset.new(id: 1) }

      specify do
        expect(subject).to be_falsy
        expect(ds.doi_status).to eq(:error)
        expect(ds.doi_message).to include('DOI was not generated')
      end
    end

    context 'all mandatory properties present' do
      let(:ds) { FactoryGirl.create(:dataset) }

      specify do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#update_or_create_doi' do
    let(:ds) { Dataset.new }
    subject { ds.send(:update_or_create_doi) }

    context "can't get doi" do
      before do
        expect(ds).to receive(:can_get_doi?) { false }
      end

      specify do
        expect(ds).not_to receive(:update_doi_metadata)
        expect(ds).not_to receive(:create_doi)
        subject
      end
    end

    context "can get doi" do
      before do
        expect(ds).to receive(:can_get_doi?) { true }
      end

      context 'no doi' do
        specify do
          expect(ds).not_to receive(:update_doi_metadata)
          expect(ds).to receive(:create_doi)
          subject
        end
      end

      context 'doi already there' do
        let(:ds) { Dataset.new(doi: 'ABC') }

        specify do
          expect(ds).to receive(:update_doi_metadata)
          expect(ds).not_to receive(:create_doi)
          subject
        end
      end
    end
  end
end
