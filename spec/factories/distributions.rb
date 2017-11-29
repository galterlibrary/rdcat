# == Schema Information
#
# Table name: distributions
#
#  id          :integer          not null, primary key
#  dataset_id  :integer
#  uri         :string
#  name        :string
#  description :text
#  format      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  artifact    :string
#

FactoryGirl.define do
  factory :distribution do
    name {|n| Faker::Hipster.word + "-#{n}" }
    association :dataset, factory: :dataset
  end
end
