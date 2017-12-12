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
        visit "/datasets/#{dataset.id}/distributions/#{distribution.id}"
      end

      it 'shows the MIME and descriptive file information' do
        expect(page).to have_text('5 Bytes')
        expect(page).to have_text('text/plain')
        expect(page).to have_text('ASCII text')
      end
    end
  end
end
