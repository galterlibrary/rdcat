# == Schema Information
#
# Table name: datasets
#
#  id              :integer          not null, primary key
#  title           :string
#  description     :text
#  license         :string
#  organization_id :integer
#  visibility      :string
#  state           :string
#  source          :string
#  version         :string
#  author_id       :integer
#  maintainer_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :dataset do
    
  end
end
