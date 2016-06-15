# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  username               :string           not null
#  first_name             :string
#  last_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

FactoryGirl.define do

  sequence :email do |n|
    "#{n}_#{Faker::Internet.email}"
  end

  sequence :username do |n|
    "#{n}_#{Faker::Internet.user_name}"
  end

  sequence :password do |n|
    "#{n}_#{Devise.friendly_token[0,20]}"
  end

  factory :user do
    email
    username
    password
    admin false
    factory :admin do
      admin true
    end
  end
end
