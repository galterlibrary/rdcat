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

  after_save do
    if self.dataset.present?
      self.dataset.__elasticsearch__.index_document
    end
  end
  around_destroy :update_dataset_index

  def update_dataset_index
    ds = self.dataset
    yield
    ds.__elasticsearch__.index_document
  end

  mount_uploader :artifact, ArtifactUploader
end
