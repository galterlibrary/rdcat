# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string
#  abbreviation :string
#  email        :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Organization, :type => :model do
  it { should have_many(:datasets) }
  
  it { should validate_uniqueness_of(:name) }
  it { should validate_uniqueness_of(:abbreviation) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:url) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:abbreviation) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:url) }
end
