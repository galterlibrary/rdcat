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

require 'rails_helper'

RSpec.describe License, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
