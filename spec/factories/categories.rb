# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uniq_id     :string
#  description :text
#  matchers    :string           is an Array
#

FactoryGirl.define do
  factory :category do
    name "MyString"
  end
end
