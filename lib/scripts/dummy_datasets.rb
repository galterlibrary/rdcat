# can be run after seeding the db and there are two users created
require 'faker'

users = [User.first, User.second]
visibility = ["Private", "Public"]
categories = ["Sharks", "Leg", "Arm", "Hand", "Foot"]

10.times do 
  Dataset.create(title: Faker::Book.unique.title, 
    description: Faker::Hipster.paragraph(8),
    organization_id: rand(1..17),
    visibility: visibility.sample,
    state: "Active",
    version: "1.0",
    author_id: users.sample.id,
    maintainer_id: users.sample.id,
    categories: categories.sample(rand(1..4)),
    grants_and_funding: Faker::ChuckNorris.fact
    )
end
