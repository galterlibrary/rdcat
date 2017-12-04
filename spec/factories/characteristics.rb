# == Schema Information
#
# Table name: characteristics
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :characteristic do
    name "MyString"
  end
end
