# == Schema Information
#
# Table name: dataset_organizations
#
#  id              :integer          not null, primary key
#  dataset_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DatasetOrganization < ApplicationRecord
  belongs_to :dataset
  belongs_to :organization

  validates :dataset_id, presence: true
  validates :organization_id, presence: true
end
