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

class Dataset < ApplicationRecord
  belongs_to :organization
  belongs_to :author, class_name: 'User'
  belongs_to :maintainer, class_name: 'User'
  has_many :distributions

  validates :title, presence: true, uniqueness: true
end