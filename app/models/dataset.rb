# == Schema Information
#
# Table name: datasets
#
#  id                 :integer          not null, primary key
#  title              :string
#  description        :text
#  license            :string
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
#  fast_categories    :text             default([]), is an Array
#

class Dataset < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include EzidGenerator

  index_name Rails.application.class.parent_name.underscore
  document_type self.name.downcase

  belongs_to :author, class_name: 'User'
  belongs_to :maintainer, class_name: 'User'
  belongs_to :characteristic
  has_many :distributions
  has_many :dataset_organizations
  has_many :organizations, :through => :dataset_organizations
  scope :departments, -> {
    joins(:dataset_organizations).joins(:organizations).where(
      'organizations.org_type = ?', Organization.org_types['department']
    )
  }
  scope :research_cores, -> {
    joins(:dataset_organizations).joins(:organizations).where(
      'organizations.org_type = ?', Organization.org_types['research_core']
    )
  }
  scope :institutes_and_centers, -> {
    joins(:dataset_organizations).joins(:organizations).where(
      'organizations.org_type = ?', Organization.org_types['institute_or_center']
    )
  }

  validates :title, presence: true, uniqueness: true
  validates :maintainer, presence: true
  validates :author, presence: true

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
    begin
      __elasticsearch__.delete_index!
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
    end
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
                 fields: [
                   'title^10',
                   'doi^10',
                   'description^5',
                   'categories^3',
                   'fast_categories^3',
                   'license',
                   'source',
                   'author.*',
                   'maintainer.*',
                   'distributions.name^5',
                   'distributions.description^3',
                   'distributions.format'
                 ],
                 operator: 'and',
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
      indexes :fast_categories, analyzer: 'english'
      indexes :source, analyzer: 'english'
      indexes :doi
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
      only: [
        :title, :description, :license, :fast_categories, :categories, :source,
        :doi
      ],
      include: {
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

  def self.chosen_categories(ctype='categories')
    pluck(ctype).flatten.select{ |c| !c.blank? }.uniq.sort
  end

  def self.known_organizations
    Organization.order(:name).where(
      id: DatasetOrganization.pluck(:organization_id)
    ).distinct.to_a
  end

  def public?
    self.visibility == self.class::PUBLIC
  end

  def orgs(otype)
    organizations.where(org_type: Organization.org_types[otype])
  end
end
