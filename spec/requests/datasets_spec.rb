require 'rails_helper'

RSpec.describe 'Datasets', :type => :request do
  describe 'search', elasticsearch: true do
    before do
      FactoryGirl.create(:dataset, title: 'Hello')
      Dataset.__elasticsearch__.refresh_index!
    end

    it 'can search' do
      visit datasets_path
      expect(page).to have_text('Hello')
      within('#dataset_search_form') do
        fill_in 'q', with: "won't match"
        click_button 'Search'
      end
      expect(page).not_to have_text('Hello')

      within('#dataset_search_form') do
        fill_in 'q', with: "hello"
        click_button 'Search'
      end
      expect(page).to have_text('Hello')
    end
  end
end
