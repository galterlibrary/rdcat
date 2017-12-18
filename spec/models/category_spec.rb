# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uniq_id     :string
#  description :text
#  matchers    :string           is an Array
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'basic checks' do
    before do
      stub_request(:any, /localhost:9250/)
    end

    specify do
      expect(subject).to validate_uniqueness_of(:name)
      expect(subject).to validate_presence_of(:name)
    end
  end

  describe 'elasticsearch integration', elasticsearch: true do
    before do
      FactoryGirl.create(:category, name: 'nomatch1')
      FactoryGirl.create(:category, name: 'nomatch2')
      FactoryGirl.create(:category, name: 'nomatch3')
      @test = FactoryGirl.create(:category, name: 'testus')
      FactoryGirl.create(:category, name: 'Test1')
      FactoryGirl.create(:category, name: 'test2')
      FactoryGirl.create(:category, name: 'Testing')
      FactoryGirl.create(:category, name: 'test it')
      Category.__elasticsearch__.refresh_index!
    end

    context 'self#elastic_suggest' do
      subject { Category.elastic_suggest('te', 'mesh-suggest') }

      it 'returns suggestions' do
        expect(subject).to be_an_instance_of(
          Elasticsearch::Model::Response::Response
        )
        suggestions = subject.suggestions['mesh-suggest']
                             .first['options']
                             .map {|o| o['text'] }
        expect(suggestions).to include('testus')
        expect(suggestions).to include('Test1')
        expect(suggestions).to include('test2')
        expect(suggestions).to include('Testing')
        expect(suggestions).to include('test it')
        expect(suggestions.count).to eq(5)
      end

      describe 'with size limit' do
        subject { Category.elastic_suggest('te', 'mesh-suggest', 2) }

        it 'returns suggestions' do
        end
      end

      context 'with matchers' do
        subject { Category.elastic_suggest('te', 'mesh-suggest') }

        before do
          FactoryGirl.create(
            :category, name: 'not-name match', matchers: ['testingus', 'nope']
          )
          Category.__elasticsearch__.refresh_index!
        end

        it 'returns suggestions' do
          expect(subject).to be_an_instance_of(
            Elasticsearch::Model::Response::Response
          )
          suggestions = subject.suggestions['mesh-suggest']
                               .first['options']
                               .map {|o| o['text'] }
          expect(suggestions).to include('testus')
          expect(suggestions).to include('Test1')
          expect(suggestions).to include('test2')
          expect(suggestions).to include('Testing')
          expect(suggestions).to include('test it')
          expect(suggestions).to include('testingus')
          expect(suggestions.count).to eq(6)
        end
      end
    end

    context 'self#formatted_suggestions' do
      subject { Category.formatted_suggestions('testu', 1) }

      it 'returns suggestions' do
        expect(subject.count).to eq(1)
        expect(subject).to include(
          {
            text: 'testus',
            description: @test.description,
            mesh_id: @test.uniq_id,
            matchers: @test.matchers,
            id: @test.id,
            matched: 'testus',
            prefix: 'testu'
          }
        )
      end

      describe 'when non-name match' do
        subject { Category.formatted_suggestions('testi', 1) }

        before do
          @test = FactoryGirl.create(
            :category, name: 'not-name match', matchers: ['testingus', 'nope']
          )
          Category.__elasticsearch__.refresh_index!
        end

        it 'returns suggestions with name in the text field' do
          expect(subject.count).to eq(1)
          expect(subject).to include(
            {
              text: 'not-name match',
              description: @test.description,
              matchers: @test.matchers,
              mesh_id: @test.uniq_id,
              id: @test.id,
              matched: 'testingus',
              prefix: 'testi'
            }
          )
        end
      end
    end
  end
end
