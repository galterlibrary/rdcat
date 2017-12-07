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

  before_save :check_content_type_and_format

  def check_content_type_and_format
    return unless self.artifact.current_path
    if self.artifact.content_type.blank?
      self.artifact.file.content_type = `file -b --mime-type #{artifact.current_path}`.to_s.strip
    end
    if self.format.blank?
      self.format = `file -b #{artifact.current_path}`.to_s.strip
    end
  end
  private :check_content_type_and_format

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
  
  def pretty_date
    self.updated_at.strftime("%b %d, %Y")
  end

  mount_uploader :artifact, ArtifactUploader
end
