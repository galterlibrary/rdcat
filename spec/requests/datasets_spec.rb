require 'rails_helper'

RSpec.describe 'Datasets', :type => :request, elasticsearch: true do
  let(:user)  { FactoryGirl.create(:user) }

  describe 'edit and update' do
    let!(:ds1) {
      FactoryGirl.create(:dataset, title: 'Hello', maintainer: user)
    }

    before do
      Dataset.__elasticsearch__.refresh_index!
    end

    context 'anonymous user' do
      it 'cannot edit' do
        visit edit_dataset_path(ds1)
        expect(page).to have_text('You need to sign in')
      end
    end

    context 'logged in as the owner' do
      before do
        login_as user
        FactoryGirl.create(:user, first_name: 'Boo', last_name: 'Hoo')
        FactoryGirl.create(:characteristic, name: 'Wet')
        FactoryGirl.create(:license, title: 'Brutal')
        Dataset.__elasticsearch__.refresh_index!
      end

      it 'can edit' do
        visit dataset_path(ds1)
        expect(page).to have_link('Edit')
        click_link 'Edit'
        within('.edit_dataset') do
          fill_in 'Title', with: 'Numbers and such'
          fill_in 'Description', with: 'Normal things 123'
          fill_in 'Grants and funding', with: '$5 million monies'
          select 'Boo Hoo', from: 'Author'
          select 'Wet', from: 'Characteristic'
          select 'Deleted', from: 'State'
          fill_in 'Source', with: 'computerz'
          select 'Brutal', from: 'License'
          fill_in 'Version', with: 'R2D2'
        end
        click_button 'Update Dataset'
        
        # Updated values on show page
        expect(page).to have_text('Numbers and such')
        expect(page).to have_text('Normal things 123')
        expect(page).to have_text('$5 million monies')
        expect(page).to have_text('Dataset was successfully updated')
        expect(page).to have_text('Wet')
        expect(page).to have_text('Boo Hoo')
        expect(page).to have_text('Deleted')
        expect(page).to have_text('computerz')
        expect(page).to have_text('Brutal')
        expect(page).to have_text('R2D2')

        #FIXME Test visibility and maintainer
        visit edit_dataset_path(ds1)
        select 'Private', from: 'Visibility'
        select 'Boo Hoo', from: 'Maintainer'
        click_button 'Update Dataset'
        # Maintener has been changed, can't edit
        expect(page).not_to have_link('Edit')
        logout
        visit dataset_path(ds1)
        #FIXME - this shouldn't work
        expect(current_path).to eq(dataset_path(ds1))
        expect(page).to have_text('Numbers and such')
      end
    end
  end

  context 'distributions info' do 
    let(:dataset) { FactoryGirl.create(:dataset) }

    context 'with artifact' do
      let(:distribution) {
        FactoryGirl.create(:distribution, dataset: dataset, format: nil)
      }

      before do
        File.open('spec/fixtures/artifact1.txt') {|f|
          distribution.artifact.store!(f)
        }
        distribution.save!
        visit dataset_path(dataset)
      end

      it 'shows the MIME and descriptive file information' do
        expect(page).to have_link('Download (5 Bytes)')
        expect(page).to have_text('text/plain')
        expect(page).to have_text('ASCII text')
      end
    end
  end

  describe 'search' do
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
