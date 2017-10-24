# == Schema Information
#
# Table name: datasets
#
#  id              :integer          not null, primary key
#  title           :string
#  description     :text
#  license         :string
#  organization_id :integer
#  visibility      :string
#  state           :string
#  source          :string
#  version         :string
#  author_id       :integer
#  maintainer_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  categories      :text             default([]), is an Array
#

class Dataset < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name Rails.application.class.parent_name.underscore
  document_type self.name.downcase

  belongs_to :organization
  belongs_to :author, class_name: 'User'
  belongs_to :maintainer, class_name: 'User'
  has_many :distributions

  validates :title, presence: true, uniqueness: true
  validates :organization, presence: true
  validates :maintainer, presence: true

  # Visibility
  PUBLIC   = 'Public'
  PRIVATE  = 'Private'
  VISIBILITY_OPTIONS = [ PUBLIC, PRIVATE ]
  
  # State
  ACTIVE   = 'Active'
  DELETED  = 'Deleted'
  STATE_OPTIONS = [ ACTIVE, DELETED ]

  validates :visibility, inclusion: { in: VISIBILITY_OPTIONS }
  validates :state, inclusion: { in: STATE_OPTIONS }

  def self.reindex!
    __elasticsearch__.delete_index!
    __elasticsearch__.create_index!
    import
  end

  def self.search(query, current_netid: nil)
     __elasticsearch__.search(
       {
         query: {
           bool: {
             must: {
               multi_match: {
                 operator: 'and',
                 fields: [
                   'title^10',
                   'description^5',
                   'categories^3',
                   'license',
                   'source',
                   'organization.name',
                   'author.*',
                   'maintainer.*',
                   'distributions.name^5',
                   'distributions.description^3',
                   'distributions.format'
                 ],
                 query: query
               }
             },
             filter: {
               terms: {
                 view_authz: (['OPENZ'] | [current_netid]).compact
               }
             }
           }
         }
       }
     )
  end

  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :title, analyzer: 'english'
      indexes :description, analyzer: 'english'
      indexes :license, analyzer: 'english'
      indexes :categories, analyzer: 'english'
      indexes :source, analyzer: 'english'
      indexes :organization do
        indexes :name, analyzer: 'english'
      end
      indexes :author do
        indexes :name, analyzer: 'english'
        indexes :email, analyzer: 'english'
      end
      indexes :maintainer do
        indexes :name, analyzer: 'english'
        indexes :email, analyzer: 'english'
      end
      indexes :distributions do
        indexes :name, analyzer: 'english'
        indexes :description, analyzer: 'english'
        indexes :format, analyzer: 'english'
      end
      indexes :view_authz, type: 'keyword'
    end
  end

  def as_indexed_json(options={})
    self.as_json(
      only: [:title, :description, :license, :categories, :source],
      include: {
        organization: { only: :name },
        author: { only: [:email], methods: [:name] },
        maintainer: { only: [:email], methods: [:name] },
        distributions: { only: [:name, :description, :format] }
      },
      methods: [:view_authz]
    )
  end

  def view_authz
    if visibility == 'Private'
      [
        author.try(:username),
        maintainer.try(:username)
      ].compact.map {|o| o.to_s.downcase }
    else
      ['OPENZ']
    end
  end

  def self.chosen_categories
    pluck('categories').flatten.select{ |c| !c.blank? }.uniq.sort
  end

  def self.known_organizations
    Organization.order(:name).where(id: pluck(:organization_id)).distinct.to_a
  end
end
