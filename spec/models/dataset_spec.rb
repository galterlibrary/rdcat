# == Schema Information
#
# Table name: datasets
#
#  id                 :integer          not null, primary key
#  title              :string
#  description        :text
#  license            :string
#  organization_id    :integer
#  visibility         :string
#  state              :string
#  source             :string
#  version            :string
#  author_id          :integer
#  maintainer_id      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  categories         :text             default([]), is an Array
#  characteristic_id  :integer
#  grants_and_funding :text
#  doi                :string
#

require 'rails_helper'

RSpec.describe Dataset, :type => :model do
  describe 'basic checks' do
    before do
      stub_request(:any, /localhost:9250/)
    end

    specify do
      expect(subject).to have_many(:distributions)
      expect(subject).to belong_to(:organization)
      expect(subject).to belong_to(:author)
      expect(subject).to belong_to(:maintainer)

      expect(subject).to validate_uniqueness_of(:title)
      expect(subject).to validate_presence_of(:title)
      expect(subject).to validate_presence_of(:organization)
      expect(subject).to validate_presence_of(:maintainer)
    end
  end

  describe 'elasticsearch integration', elasticsearch: true do
    before do
      FactoryGirl.create(:dataset, title: "NEVERMATCH")
    end

    context 'title' do
      before do
        FactoryGirl.create(:dataset, title: "Blood Meridian's Dataset")
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('Blood') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(subject.first.title).to eq("Blood Meridian's Dataset")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Blood Meridian's Dataset") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.title).to eq("Blood Meridian's Dataset")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'description' do
      before do
        FactoryGirl.create(
          :dataset,
          :description => "The ultimate trade awaiting its ultimate practitioner"
        )
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end

      context 'search for a single word' do
        subject { Dataset.search('ultimate') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(subject.first.description).to include("The ultimate trade")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search(
          "The ultimate trade awaiting its ultimate practitioner" )}

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.description).to include("The ultimate trade")
        end
      end
    end

    context 'categories' do
      before do
        FactoryGirl.create(:dataset, :categories => ['Cat1', 'Asdf, fdas'])
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end

      context 'search for a single word' do
        subject { Dataset.search('asdf') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(subject.first.categories).to include("Cat1")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search('Cat1') }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.categories).to include("Cat1")
        end
      end
    end

    context 'license' do
      before do
        FactoryGirl.create(:dataset, license: "Blood Meridian's License")
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('Blood') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(subject.first.license).to eq("Blood Meridian's License")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Blood Meridian's License") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.license).to eq("Blood Meridian's License")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'source' do
      before do
        FactoryGirl.create(:dataset, source: "Blood Meridian's Source")
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('Blood') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(subject.first.source).to eq("Blood Meridian's Source")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Blood Meridian's Source") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.source).to eq("Blood Meridian's Source")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'organization' do
      before do
        FactoryGirl.create(
          :dataset,
          :organization => FactoryGirl.create(
            :organization, name: "Blood Meridian's Org"
          )
        )
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('Blood') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.organization['name']
          ).to eq("Blood Meridian's Org")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Blood Meridian's Org") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.organization['name']
          ).to eq("Blood Meridian's Org")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'author' do
      before do
        FactoryGirl.create(
          :dataset,
          :author => FactoryGirl.create(
            :user,
            first_name: 'Zdenek',
            last_name: 'Smetana',
            email: 'tris@ti.an'
          )
        )
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('smetana') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.author['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Zdenek Smetana") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.author['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search for email' do
        subject { Dataset.search("tris@ti.an") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.author['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'maintainer' do
      before do
        FactoryGirl.create(
          :dataset,
          :maintainer => FactoryGirl.create(
            :user,
            first_name: 'Zdenek',
            last_name: 'Smetana',
            email: 'tris@ti.an'
          )
        )
        Dataset.__elasticsearch__.refresh_index!
      end

      context 'search for a single word' do
        subject { Dataset.search('smetana') }

        it 'ignores case, and punctuation' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.maintainer['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search for an exact pharase' do
        subject { Dataset.search("Zdenek Smetana") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.maintainer['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search for email' do
        subject { Dataset.search("tris@ti.an") }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(
            subject.first.maintainer['name']
          ).to eq("Zdenek Smetana")
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    context 'distributions' do
      before do
        FactoryGirl.create(
          :distribution,
          name: "Dataset's Distro",
          description: "Dataset's Description",
          format: 'jpeg'
        )
        Dataset.import
        Dataset.__elasticsearch__.refresh_index!
      end

      describe 'name' do
        context 'search for a single word' do
          subject { Dataset.search('distro') }

          it 'ignores case, and punctuation' do
            expect(subject.count).to eq(1)
            expect(
              subject.first.distributions.first['name']
            ).to eq("Dataset's Distro")
          end
        end

        context 'search for an exact pharase' do
          subject { Dataset.search("Dataset's Distro") }

          it 'matches' do
            expect(subject.count).to eq(1)
            expect(
              subject.first.distributions.first['name']
            ).to eq("Dataset's Distro")
          end
        end
      end

      describe 'description' do
        context 'search for a single word' do
          subject { Dataset.search('description') }

          it 'ignores case, and punctuation' do
            expect(subject.count).to eq(1)
            expect(
              subject.first.distributions.first['name']
            ).to eq("Dataset's Distro")
          end
        end

        context 'search for an exact pharase' do
          subject { Dataset.search("Dataset's Description") }

          it 'matches' do
            expect(subject.count).to eq(1)
            expect(
              subject.first.distributions.first['name']
            ).to eq("Dataset's Distro")
          end
        end
      end

      describe 'format' do
        context 'search for a single word' do
          subject { Dataset.search('JPEG') }

          it 'ignores case, and punctuation' do
            expect(subject.count).to eq(1)
            expect(
              subject.first.distributions.first['name']
            ).to eq("Dataset's Distro")
          end
        end
      end

      context 'search an invalid word' do
        subject { Dataset.search("will not match") }

        it 'will not match' do
          expect(subject.count).to eq(0)
        end
      end
    end

    describe 'netid passed for public dataset' do
      before do
        FactoryGirl.create(
          :dataset,
          maintainer: FactoryGirl.create(:user, username: 'alibaba'),
          visibility: 'Public',
          title: "Blood Meridian's Dataset"
        )
        Dataset.__elasticsearch__.refresh_index!
      end

      subject { Dataset.search('Blood', current_netid: 'nonsense') }

      it 'matches' do
        expect(subject.count).to eq(1)
        expect(subject.first.title).to eq("Blood Meridian's Dataset")
      end
    end

    context 'private datasets' do
      describe 'authorized visibility does not match the passed netid' do
        before do
          FactoryGirl.create(
            :dataset,
            visibility: 'Private',
            title: "Blood Meridian's Dataset"
          )
          Dataset.__elasticsearch__.refresh_index!
        end

        subject { Dataset.search('Blood', current_netid: 'nonsense') }

        it 'does not match' do
          expect(subject.count).to eq(0)
        end
      end

      describe 'author matches the passed netid' do
        before do
          FactoryGirl.create(
            :dataset,
            author: FactoryGirl.create(:user, username: 'alibaba'),
            visibility: 'Private',
            title: "Blood Meridian's Dataset"
          )
          Dataset.__elasticsearch__.refresh_index!
        end

        subject { Dataset.search('Blood', current_netid: 'alibaba') }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.title).to eq("Blood Meridian's Dataset")
        end
      end

      describe 'author matches the passed netid' do
        before do
          FactoryGirl.create(
            :dataset,
            maintainer: FactoryGirl.create(:user, username: 'alibaba'),
            visibility: 'Private',
            title: "Blood Meridian's Dataset"
          )
          Dataset.__elasticsearch__.refresh_index!
        end

        subject { Dataset.search('Blood', current_netid: 'alibaba') }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.title).to eq("Blood Meridian's Dataset")
        end
      end

      describe 'author and maintainer matches the passed netid' do
        before do
          u = FactoryGirl.create(:user, username: 'alibaba')
          FactoryGirl.create(
            :dataset,
            maintainer: u,
            author: u,
            visibility: 'Private',
            title: "Blood Meridian's Dataset"
          )
          Dataset.__elasticsearch__.refresh_index!
        end

        subject { Dataset.search('Blood', current_netid: 'alibaba') }

        it 'matches' do
          expect(subject.count).to eq(1)
          expect(subject.first.title).to eq("Blood Meridian's Dataset")
        end
      end
    end

    context 'results order' do
      subject { Dataset.search('match') }

      before do
        FactoryGirl.create(:dataset, title: 'Match it')
        FactoryGirl.create(:dataset, title: 'Second', description: 'Match me')
        FactoryGirl.create(:dataset, title: 'Third', categories: ['Match this'])
        Dataset.__elasticsearch__.refresh_index!
      end

      it 'returns results ordered based on their weights' do
        expect(subject[0].title).to eq('Match it')
        expect(subject[1].title).to eq('Second')
        expect(subject[2].title).to eq('Third')
      end
    end
  end
end
