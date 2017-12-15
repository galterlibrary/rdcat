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

class Category < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchConcerns

  index_name 'rdcat_suggest_mesh'
  document_type self.name.downcase

  validates :name, presence: true, uniqueness: true

  settings do
    mapping do
      indexes :suggest, type: 'completion'
    end
  end

  def as_indexed_json(options={})
    {
      suggest: [
        {
          input: name,
          weight: 1
        }, {
          input: matchers,
          weight: 2
        },
      ],
      name: name,
      description: description,
      mesh_id: uniq_id,
      id: id
    }
  end

  def self.formatted_suggestions(prefix, size=10)
    elastic_suggest(
      prefix, 'mesh-suggest', size
    ).suggestions['mesh-suggest'].first['options'].map do |sug|
      {
        text: sug['_source']['name'],
        description: sug['_source']['description'],
        mesh_id: sug['_source']['mesh_id'],
        id: sug['_source']['id']
      }
    end
  end
end
