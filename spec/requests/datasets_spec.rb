require 'rails_helper'

RSpec.describe 'Datasets', :type => :request, elasticsearch: true do
  let(:user)  { FactoryGirl.create(:user) }

  before do
    allow_any_instance_of(Dataset).to receive(:update_or_create_doi)
    allow_any_instance_of(Dataset).to receive(:deactivate_or_remove_doi)
  end

  let!(:ds1) {
    FactoryGirl.create(
      :dataset, title: 'Hello', maintainer: user
    )
  }

  before do
    Dataset.__elasticsearch__.refresh_index!
  end

  context 'anonymous user' do
    it 'cannot edit' do
      visit edit_dataset_path(ds1)
      expect(page).to have_text('You need to sign in')
    end
    
    it 'does not show doi, edit, destroy links' do
      visit dataset_path(ds1)
      expect(page).to_not have_link('Mint DOI')
      expect(page).to_not have_link('Edit')
      expect(page).to_not have_link('Destroy')
    end
  end

  context 'logged in' do
    before do
      login_as user
      FactoryGirl.create(:user, first_name: 'Boo', last_name: 'Hoo')
      FactoryGirl.create(:characteristic, name: 'Wet')
      FactoryGirl.create(:license, title: 'Brutal')
      FactoryGirl.create(:category)
      Dataset.__elasticsearch__.refresh_index!
    end

    specify do
      # As owner
      visit dataset_path(ds1)
      click_link 'Edit'
      within('.edit_dataset') do
        fill_in 'Title', with: 'Numbers and such'
        fill_in 'Description', with: 'Normal things 123'
        fill_in 'Grants and funding', with: '$5 million monies'
        select 'Boo Hoo', from: 'Author'
        select 'Wet', from: 'LCSH Subject'
        select 'Deleted', from: 'State'
        fill_in 'Source', with: 'computerz'
        select 'Brutal', from: 'License'
        fill_in 'Version', with: 'R2D2'
        select 'MyString', from: 'MeSH Categories'
      end
      click_button 'Update Dataset'
      
      # Updated values on show page
      expect(page).to have_text('Dataset was successfully updated')
      
      expect(page).to have_link('Boo Hoo')
      expect(page).to have_text('Version R2D2')
      expect(page).to have_link('MyString', href: '/datasets?category=MyString')
      expect(page).to have_text('Deleted')
      
      expect(page).to have_text('Numbers and such')
      expect(page).to have_text('Normal things 123')
      
      expect(page).to have_text('Grants and Funding')
      expect(page).to have_text('$5 million monies')
      
      expect(page).to have_text('Library of Congress Subject Heading (LCSH)')
      expect(page).to have_text('Wet')
      
      expect(page).to have_text('Source')
      expect(page).to have_text('computerz')
      
      expect(page).to have_text('License')
      expect(page).to have_text('Brutal')
      
      expect(page).to have_text('Distributions: 0')
      expect(page).to have_text('No distributions exist for dataset.')
      
      # DOI minting
      allow_any_instance_of(Dataset).to receive(:update_or_create_doi) {
        ds1.doi = 'doi:10.5072/FK2W66HS5K'
        ds1.save
      }
      click_link('Mint DOI')
      expect(page).to have_link(
        'doi:10.5072/FK2W66HS5K',
        href: 'https://dx.doi.org/doi:10.5072/FK2W66HS5K'
      )
      expect(page).not_to have_link('Mint DOI')
      ds1.update_attributes(doi: nil)
      visit dataset_path(ds1)
      expect(page).to have_link('Mint DOI')

      visit edit_dataset_path(ds1)
      select 'Private', from: 'Visibility'
      select 'Boo Hoo', from: 'Maintainer'
      click_button 'Update Dataset'
      expect(page).not_to have_link('Edit')
      expect(page).not_to have_link('Mint DOI')

      # Strangers can't view
      login_as FactoryGirl.create(:user)
      visit dataset_path(ds1)
      expect(current_path).to eq('/')
      expect(page).to have_text('You cannot perform this action')
      
      # anonymous can't view 
      logout user
      visit dataset_path(ds1)
      expect(current_path).to eq("/")
      expect(page).to have_text('You cannot perform this action')
    end

    describe 'FAST subjects', js: true do
      before do
        FactoryGirl.create(:fast_subject, label: 'test1')
        FactoryGirl.create(:fast_subject, label: 'Testing FAST')
        #FIXME something strnge going on with this index
        FastSubject.__elasticsearch__.delete_index!
        FastSubject.__elasticsearch__.create_index!
        FastSubject.import
        #FIXME the above three lines shouldn't be needed
        FastSubject.__elasticsearch__.refresh_index!
      end

      specify do
        visit dataset_path(ds1)
        click_link 'Edit'
        expect(page).not_to have_text('Testing FAST')
        # Completion triggering
        within('.dataset_fast_categories') do
          search_field = '.select2-search input.select2-search__field'
          find(:xpath, "//body").find(search_field).set('te')
          page.execute_script("$('#{search_field}').keyup();")
        end
        expect(page).to have_text('Testing FAST')
        expect(page).to have_text('test1')

        # Lading of exising subjects
        visit edit_dataset_path(ds1)
        expect(page).not_to have_text('Testing FAST')
        ds1.fast_categories = ['Testing FAST']
        ds1.save!
        visit dataset_path(ds1)
        expect(page).to have_text('Testing FAST')
        click_link 'Edit'
        expect(page).to have_text('Testing FAST')
      end
    end
  end

  context 'distributions info' do 
    let(:dataset) { FactoryGirl.create(:dataset, author: user) }

    context 'with artifact' do
      let(:distribution) {
        FactoryGirl.create(:distribution, dataset: dataset, format: nil, name: 'Distro')
      }

      before do
        File.open('spec/fixtures/artifact1.txt') {|f|
          distribution.artifact.store!(f)
        }
        distribution.save!
      end

      context 'as anonymous' do
        it 'shows descriptive file information' do
          visit dataset_path(dataset)
          expect(page).to have_text('Distributions: 1')
          expect(page).to have_link(
            'Distro', href: "/datasets/#{dataset.id}/distributions/#{distribution.id}"
          )
          expect(page).to have_link('Download (5 Bytes)')
          expect(page).to have_text('text/plain')
          expect(page).to_not have_text('ASCII text')
          expect(page).to_not have_link(href: "/datasets/#{dataset.id}/distributions/new")
        end
      end
      
      context 'as author' do
        it 'shows link for new dataset' do
          login_as user
          visit dataset_path(dataset)
          expect(page).to have_link(href: "/datasets/#{dataset.id}/distributions/new")
        end
      end
    end
  end

  describe 'search' do
    before do
      ds1
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
