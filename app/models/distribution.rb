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

class Distribution < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true, uniqueness: true
  validates :dataset, presence: true

  mount_uploader :artifact, ArtifactUploader
end
