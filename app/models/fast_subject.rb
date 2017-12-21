# == Schema Information
#
# Table name: fast_subjects
#
#  id         :integer          not null, primary key
#  label      :string
#  identifier :string
#

class FastSubject < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchConcerns

  index_name 'rdcat_suggest'
  document_type self.name.downcase

  validates :label, presence: true
  validates :identifier, presence: true, uniqueness: true

  settings index: { number_of_shards: 1 } do
    mapping do
      indexes :suggest, type: 'completion'
    end
  end

  def as_indexed_json(options={})
    {
      suggest: { input: label },
      fast_id: identifier,
      id: id
    }
  end

  def self.formatted_suggestions(prefix, size=10)
    elastic_suggest(
      prefix, 'fast-suggest', size
    ).suggestions['fast-suggest'].first['options'].map do |sug|
      {
        text: sug['text'],
        fast_id: sug['_source']['fast_id'],
        id: sug['_source']['id'],
        prefix: prefix
      }
    end
  end
end
