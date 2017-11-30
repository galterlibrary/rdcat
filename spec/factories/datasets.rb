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

FactoryGirl.define do
  factory :dataset do
    title { Faker::Hipster.unique.word }
    association :organization, factory: :organization
    association :maintainer, factory: :user
    visibility Dataset::PUBLIC
    state Dataset::ACTIVE
  end
end
