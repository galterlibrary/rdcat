# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Load organizations
seed_file = Rails.root.join('db', 'seeds', 'organizations.yml')
orgs = YAML::load_file(seed_file)['organizations']
orgs.each do |o|
  org = Organization.where(abbreviation: o['abbreviation']).first
  if org.blank?
    Organization.create(name: o['name'], abbreviation: o['abbreviation'], url: o['url'])
  end
end

# Load categories
seed_file = Rails.root.join('db', 'seeds', 'categories.yml')
categories = YAML::load_file(seed_file)['categories']
categories.each do |c|
  Category.where(name: c['name']).first_or_create
end

License.create_records!