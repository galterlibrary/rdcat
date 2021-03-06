# == Schema Information
#
# Table name: fast_subjects
#
#  id         :integer          not null, primary key
#  label      :string
#  identifier :string
#

require 'rails_helper'

RSpec.describe FastSubject, :type => :model do
  describe 'basic checks' do
    before do
      stub_request(:any, /localhost:9250/)
    end

    specify do
      expect(subject).to validate_presence_of(:identifier)
    end
  end

  describe 'elasticsearch integration', elasticsearch: true do
    before do
      FactoryGirl.create(:fast_subject, label: 'nomatch1')
      FactoryGirl.create(:fast_subject, label: 'nomatch2')
      FactoryGirl.create(:fast_subject, label: 'nomatch3')
      @test = FactoryGirl.create(:fast_subject, label: 'test')
      FactoryGirl.create(:fast_subject, label: 'Test1')
      FactoryGirl.create(:fast_subject, label: 'test2')
      FactoryGirl.create(:fast_subject, label: 'Testing')
      FactoryGirl.create(:fast_subject, label: 'test it')
      FastSubject.__elasticsearch__.refresh_index!
    end

    context 'self#elastic_suggest' do
      subject { FastSubject.elastic_suggest('te', 'fast-suggest') }

      it 'returns suggestions' do
        expect(subject).to be_an_instance_of(
          Elasticsearch::Model::Response::Response
        )
        suggestions = subject.suggestions['fast-suggest']
                             .first['options']
                             .map {|o| o['text'] }
        expect(suggestions).to include('test')
        expect(suggestions).to include('Test1')
        expect(suggestions).to include('test2')
        expect(suggestions).to include('Testing')
        expect(suggestions).to include('test it')
        expect(suggestions.count).to eq(5)
      end

      describe 'with size limit' do
        subject { FastSubject.elastic_suggest('te', 'fast-suggest', 2) }

        it 'returns suggestions' do
          expect(subject).to be_an_instance_of(
            Elasticsearch::Model::Response::Response
          )
          suggestions = subject.suggestions['fast-suggest']
                               .first['options']
                               .map {|o| o['text'] }
          expect(suggestions.count).to eq(2)
        end
      end
    end

    context 'self#formatted_suggestions' do
      subject { FastSubject.formatted_suggestions('te', 1) }

      it 'returns suggestions' do
        expect(subject.count).to eq(1)
        expect(subject).to include(
          {
            text: 'test',
            fast_id: @test.identifier,
            id: @test.id,
            prefix: 'te'
          }
        )
      end
    end
  end
end
