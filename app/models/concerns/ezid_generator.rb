module EzidGenerator
  extend ActiveSupport::Concern

  attr_accessor :doi_message, :doi_status

  def ezid_metadata(status)
    Ezid::Metadata.new(
      'datacite.creator' => self.author.try(:name) || self.maintainer.name,
      'datacite.title' => self.title,
      'datacite.publisher' => 'Galter Health Science Library',
      'datacite.publicationyear' => self.created_at.year,
      '_status' => status,
      '_target' => "#{ENV['PRODUCTION_URL']}/datasets/#{self.id}"
    )
  end
  private :ezid_metadata

  def update_doi_metadata_message(identifier, new_status)
    self.doi_message = 'DOI metadata was updated.'
    if new_status == 'unavailable' && identifier.status != new_status
      self.doi_status = :alert
      self.doi_message += " Because your document lacks permission for public viewing, the DOI has been deactivated. Please modify the file's visibility to 'Public' for the DOI to be activated."
    end
  end
  private :update_doi_metadata_message

  def update_doi_metadata
    return if self.doi.blank?
    begin
      identifier = Ezid::Identifier.find(self.doi.to_s.strip)
      new_status = self.public? ? 'public' : 'unavailable'
      update_doi_metadata_message(identifier, new_status)
      identifier.update_metadata(ezid_metadata(new_status))
      identifier.save
    rescue Ezid::Error
      self.doi_status = :error
      self.doi_message = "DOI metadata was not updated."
    end
  end
  private :update_doi_metadata

  def create_doi
    identifier = Ezid::Identifier.mint(
      ezid_metadata(self.public? ? 'public' : 'reserved')
    )
    self.update_attributes(doi: identifier.id)
    self.doi_message = 'DOI was generated.'
    if identifier.status == 'reserved'
      self.doi_status = :alert
      self.doi_message +=  " Because your document lacks permission for public viewing, the DOI is inactive. Please modify the file's visibility to 'Public' for the DOI to be activated."
    end
  end
  private :create_doi

  def can_get_doi?
    # Only generate if required metadata is there
    # This is for the times when dataset was not successfully created
    unless self.id.present? && self.maintainer.present? && self.title.present?
      self.doi_status = :error
      self.doi_message = "DOI was not generated, because the file is missing required metadata. Please edit the file to generate a DOI."
      return false
    end
    true
  end
  private :can_get_doi?

  def update_or_create_doi
    self.doi_status = :notice
    return unless can_get_doi?
    if self.doi.present?
      update_doi_metadata
    else
      create_doi
    end
  end

  def deactivate_or_remove_doi
    return if self.doi.blank?
    identifier = Ezid::Identifier.find(self.doi)
    if identifier.status == 'reserved'
      identifier.delete
    else
      identifier.status = 'unavailable'
      identifier.save
    end
  end
end
