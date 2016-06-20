# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string
#  abbreviation :string
#  email        :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do

  factory :organization do
    name
    abbreviation
    email
    url
  end
end
