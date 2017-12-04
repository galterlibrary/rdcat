require 'zip'

puts 'Starting FAST subjects import. This will take a while...'
if ENV['FAST_IMPORT'] == 'true'
  zip_file = Zip::File.open('db/seeds/fast_subjects.zip')
  entry = zip_file.glob('*.yml').first
  ActiveRecord::Base.transaction do
    fasts = YAML::load(entry.get_input_stream.read)['fast_subjects']
    fasts.each do |f|
      fname =  f['name'].strip
      fid = f['id'].strip
      fast = FastSubject.where(label: fname, identifier: fid).first
      if fast.blank?
        fast = FastSubject.create!(label: fname, identifier: fid)
      end
    end
  end
  puts "Done, imported #{ FastSubject.count } fast subjects"
else
  puts 'Skipping FAST subject import, run with FAST_IMPORT=true to import.'
end

# Load organizations
seed_file = Rails.root.join('db', 'seeds', 'organizations.yml')
orgs = YAML::load_file(seed_file)['organizations']
orgs.each do |o|
  org = Organization.where(abbreviation: o['abbreviation']).first
  if org.blank?
    Organization.create(name: o['name'], abbreviation: o['abbreviation'], url: o['url'])
  end
end

# Load characteristics
seed_file = Rails.root.join('db', 'seeds', 'characteristics.yml')
characteristics = YAML::load_file(seed_file)['characteristics']
characteristics.each do |c|
  Characteristic.where(
    name: c['name'],
    description: c['description']
  ).first_or_create
end

License.create_records!
