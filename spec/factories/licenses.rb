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

FactoryGirl.define do
  factory :license do
    domain_content false
    domain_data false
    domain_software false
    family "MyString"
    identifier "MyString"
    maintainer "MyString"
    od_conformance "MyString"
    osd_conformance "MyString"
    status "MyString"
    title "MyString"
    url "MyString"
  end
end
