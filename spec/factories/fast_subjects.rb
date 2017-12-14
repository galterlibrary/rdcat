# == Schema Information
#
# Table name: fast_subjects
#
#  id         :integer          not null, primary key
#  label      :string
#  identifier :string
#

FactoryGirl.define do
  factory :fast_subject do
    label { Faker::Hipster.unique.words(4).join(" ") }
    sequence(:identifier) {|n| "ID#{n}"}
  end
end
