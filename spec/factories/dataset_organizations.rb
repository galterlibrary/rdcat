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

FactoryGirl.define do
  factory :dataset_organization do
    association :dataset, factory: :dataset
    association :organization, factory: :organization
  end
end
