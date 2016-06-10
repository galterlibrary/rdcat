# == Schema Information
#
# Table name: distributions
#
#  id          :integer          not null, primary key
#  dataset_id  :integer
#  uri         :string
#  name        :string
#  description :text
#  format      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  artifact    :string
#

require 'rails_helper'

RSpec.describe Distribution, :type => :model do
  it { should belong_to(:dataset) }

  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:dataset) }
end
