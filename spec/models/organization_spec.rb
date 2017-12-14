# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_type   :integer          not null
#  group_name :string
#

require 'rails_helper'

RSpec.describe Organization, :type => :model do
  subject { FactoryGirl.build(:organization) }

  it { should have_many(:datasets) }
  it { should have_many(:dataset_organizations) }
  
  it { should validate_uniqueness_of(:name).scoped_to([:org_type, :group_name]) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:org_type) }
end
