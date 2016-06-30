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

  def self.chosen_categories
    pluck('categories').flatten.select{ |c| !c.blank? }.uniq.sort
  end

  def self.known_organizations
    Organization.order(:name).where(id: pluck(:organization_id)).distinct.to_a
  end

end
