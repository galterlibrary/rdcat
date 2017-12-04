# == Schema Information
#
# Table name: licenses
#
#  id              :integer          not null, primary key
#  domain_content  :boolean
#  domain_data     :boolean
#  domain_software :boolean
#  family          :string
#  identifier      :string
#  maintainer      :string
#  od_conformance  :string
#  osd_conformance :string
#  status          :string
#  title           :string
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class License < ApplicationRecord

  # Licenses listed at http://licenses.opendefinition.org/
  CKAN_URL = 'http://licenses.opendefinition.org/licenses/groups/ckan.json'

  def self.create_records!
    build_records.each do |r| 
      p "Creating license #{r.inspect}"
      r.save!
    end
  end

  def self.build_records
    licenses = []
    get_data.each do |record|
      license = License.where(identifier: record['id']).first
      license = License.new if license.blank?
      License.column_names.each do |column_name|
        next if column_name == 'id'
        key = column_name == 'identifier' ? 'id' : column_name
        value = record[key]
        next if value.blank?
        license.send("#{column_name}=", value)
      end
      licenses << license
    end
    licenses
  end

  require 'net/http'
  require 'json'
  def self.get_data
    uri = URI(CKAN_URL)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
