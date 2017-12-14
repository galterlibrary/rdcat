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

FactoryGirl.define do
  factory :organization do
    name
    org_type :department
  end
end
