# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_type   :integer          not null
#  group_name :string
#

class Organization < ApplicationRecord
  enum org_type: [ :department, :research_core, :institute_or_center ]

  has_many :dataset_organizations
  has_many :datasets, :through => :dataset_organizations

  validates :org_type, presence: true
  validates :name, presence: true

  validates :name, uniqueness: { scope: [:org_type, :group_name] }
end
