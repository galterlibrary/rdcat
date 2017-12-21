require 'rails_helper'
RSpec.describe CategoriesController, type: :controller do
  describe '#suggestions' do
    subject { get :suggestions, params: sparams, :format => :json }
    context 'no :query param passed' do
      let(:sparams) { { size: 20 } }

      it 'returns an empty array' do
        expect(subject.body).to eq('[]')
      end
    end

    context ':query param passed' do
      let(:sparams) { { query: 'yes' } }

      before do
        expect(Category).to receive(:formatted_suggestions).with(
          'yes', 10
        ).and_return(['results'])
      end

      it 'returns suggestions' do
        expect(subject.body).to eq('["results"]')
      end
    end

    describe ':query and :size param passed' do
      let(:sparams) { { query: 'no', size: 25 } }

      before do
        expect(Category).to receive(:formatted_suggestions).with(
          'no', 25
        ).and_return(['results'])
      end

      it 'returns suggestions' do
        expect(subject.body).to eq('["results"]')
      end
    end
  end
end
