# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[
  ['Bluhm Cardiovascular Institute', 'Bluhm', 'http://heart.nm.org/'],
  ['Center for Circadian and Sleep Medicine', 'Sleep', 'http://www.feinberg.northwestern.edu/sites/sleep/'],
  ['Center for Psychosocial Research in Gastrointestinal Conditions', 'GI', 'url: http://www.medicine.northwestern.edu/divisions/gastroenterology-and-hepatology/'],
  ["Cognitive Neurology and Alzheimer's Disease Center", 'Brain', 'url: http://www.brain.northwestern.edu/about/index.html'],
  ["Illinois Women's Health Registry at Northwestern University", "Women's Health", 'http://www.womenshealth.northwestern.edu/programs/illinois-womens-health-registry'],
  ['Ken & Ruth Davee Department of Neurology', 'Neurology', 'http://www.neurology.northwestern.edu/about/index.html'],
  ['Northwestern Medicine Digestive Health Center', 'Digestive Health', 'http://digestivehealth.nm.org/'],
  ['Northwestern University Allergy, Asthma, and Immunology Clinical Research Unit', 'Allergy', 'http://www.medicine.northwestern.edu/divisions/allergy-immunology/'],
  ['Northwestern University Comprehensive Center on Obesity (NCCO)', 'Obesity', 'http://www.ncco.northwestern.edu/'],
  ['Northwestern University Comprehensive Transplant Center (CTC)', 'Transplant', 'http://www.feinberg.northwestern.edu/sites/transplant/'],
  ['Northwestern University Department of Obstetrics and Gynecology', 'OB/GYN', 'http://www.feinberg.northwestern.edu/sites/obgyn/'],
  ['Northwestern University Department of Pediatrics', 'Pediatrics', 'https://www.luriechildrens.org/en-us/Pages/index.aspx'],
  ['Northwestern University Department of Preventive Medicine', 'Preventive Medicine', 'http://www.preventivemedicine.northwestern.edu/'],
  ['Northwestern University Department of Psychiatry and Behavioral Sciences', 'Psych', 'http://psychiatry.northwestern.edu/'],
  ['Northwestern University Department of Dermatology', 'Derm', 'http://www.feinberg.northwestern.edu/sites/dermatology/'],
  ["Northwestern University Parkinson's Disease and Movement Disorders Center", "Parkinson's", 'http://www.parkinsons.northwestern.edu/'],
  ['Northwestern University Clinical and Translational Sciences Institute (NUCATS)', 'NUCATS', 'http://nucats.northwestern.edu/'],
  ['Robert H. Lurie Comprehensive Cancer Center of Northwestern University', 'Cancer', 'http://cancer.northwestern.edu/home/index.cfm'],
].each do |arr|
  Organization.create(name: arr[0], abbreviation: arr[1], url: arr[2])
end
