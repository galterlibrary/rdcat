# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uniq_id     :string
#  description :text
#  matchers    :string           is an Array
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
end
