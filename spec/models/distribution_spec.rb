# == Schema Information
#
# Table name: distributions
#
#  id          :integer          not null, primary key
#  dataset_id  :integer
#  uri         :string
#  name        :string
#  description :text
#  format      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  artifact    :string
#
require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe Distribution, :type => :model do
  include CarrierWave::Test::Matchers

  before do
    stub_request(:put, /localhost:9250/)
  end

  it { should belong_to(:dataset) }

  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:dataset) }

  describe 'when no artifact' do
    context 'when no format passed' do
      subject do
        FactoryGirl.create(:distribution, format: nil)
      end

      it 'leaves the format blank' do
        expect(subject.format).to be_blank
      end
    end

    context 'when format passed' do
      subject do
        FactoryGirl.create(:distribution, format: 'Format!')
      end

      it 'uses the passed format' do
        expect(subject.format).to eq('Format!')
      end
    end
  end

  describe 'with artifact' do
    subject { FactoryGirl.create(:distribution, format: nil) }

    before do
      File.open('spec/fixtures/artifact1.txt') { |f|
        subject.artifact.store!(f)
      }
      subject.save!
    end

    it 'fills out the format and content type of the artifact file' do
      expect(subject.artifact.content_type).to eq('text/plain')
      expect(subject.format).to eq('ASCII text')
    end

    context 'when format is specified' do
      subject { FactoryGirl.create(:distribution, format: 'Dry') }

      it 'fills out the content type of the artifact file only' do
        expect(subject.artifact.content_type).to eq('text/plain')
        expect(subject.format).to eq('Dry')
      end
    end
  end
end
