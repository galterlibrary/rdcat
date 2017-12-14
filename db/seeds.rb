require 'zip'

if ENV['FAST_IMPORT'] == 'true'
  puts 'Starting FAST subjects import. This will take a while...'
  zip_file = Zip::File.open('db/seeds/fast_subjects.zip')
  entry = zip_file.glob('*.yml').first
  fasts = YAML::load(entry.get_input_stream.read)['fast_subjects']
  fasts.each do |f|
    fname =  f['name'].strip
    fid = f['id'].strip
    fast = FastSubject.where(label: fname, identifier: fid).first
    if fast.blank?
      fast = FastSubject.create!(label: fname, identifier: fid)
    end
  end
  puts "Done, imported #{ FastSubject.count } fast subjects"
else
  puts 'Skipping FAST subject import, run with FAST_IMPORT=true to import.'
end

# Load organizations
puts "Seeding Organization"
seed_file = Rails.root.join('db', 'seeds', 'organizations.yml')
orgs = YAML::load_file(seed_file)['organizations']
orgs.each do |o|
  Organization.where(
    name: o['name'],
    org_type: Organization.org_types[o['org_type']],
    group_name: o['group_name'].blank? ? nil : o['group_name']
  ).first_or_create!
end

# Load characteristics
puts "Seeding Characteristic"
seed_file = Rails.root.join('db', 'seeds', 'characteristics.yml')
characteristics = YAML::load_file(seed_file)['characteristics']
characteristics.each do |c|
  Characteristic.where(
    name: c['name'],
    description: c['description']
  ).first_or_create
end

puts "Seeding License"
License.create_records!
