require 'rails_helper'

RSpec.describe "Distributions", type: :request, elasticsearch: true do
  let(:dataset) { FactoryGirl.create(:dataset, visibility: 'Public') }

  context 'show' do 
    context 'with artifact' do
      let(:distribution) {
        FactoryGirl.create(:distribution, dataset: dataset, format: nil)
      }

      before do
        File.open('spec/fixtures/artifact1.txt') {|f|
          distribution.artifact.store!(f)
        }
        distribution.save!
        visit dataset_distributions_path(distribution.dataset, distribution)
      end

      it 'shows the MIME and descriptive file information' do
        pending("This should work after visibility is fixed")
        expect(page).to have_text('text/plain')
        expect(page).to have_text('ASCII text')
      end
    end
  end
end
