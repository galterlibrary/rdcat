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

class Organization < ApplicationRecord
  has_many :datasets
  validates :name, presence: true, uniqueness: true
  validates :abbreviation, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
end