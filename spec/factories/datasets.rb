# == Schema Information
#
# Table name: datasets
#
#  id                 :integer          not null, primary key
#  title              :string
#  description        :text
#  license            :string
#  organization_id    :integer
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
#

FactoryGirl.define do
  factory :dataset do
    title { Faker::Hipster.unique.words(4).join(" ") }
    association :organization, factory: :organization
    association :maintainer, factory: :user
    association :author, factory: :user
    visibility Dataset::PUBLIC
    state Dataset::ACTIVE
  end
end
