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

  sequence :name do |n|
    "#{n}_#{Faker::Internet.name}"
  end
  
  sequence :first_name do |n|
    "#{n}_#{Faker::Name.first_name}"
  end
  
  sequence :last_name do |n|
    "#{n}_#{Faker::Name.last_name}"
  end

  sequence :abbreviation do |n|
    "#{n}#{Faker::Hacker.abbreviation}"
  end

  sequence :url do |n|
    "http://www#{n}.example.com"
  end

end