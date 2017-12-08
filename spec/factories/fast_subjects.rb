# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  label      :string
#  identifier :string
#

FactoryGirl.define do
  factory :fast_subject do
    label { Faker::Hipster.unique.words(4).join(" ") }
    sequence(:identifier) {|n| "ID#{n}"}
  end
end
