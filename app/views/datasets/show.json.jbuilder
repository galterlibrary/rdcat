json.extract!(
  @dataset, :id, :title, :description, :grants_and_funding, :license, :doi,
            :visibility, :state, :source, :version, :created_at, :updated_at
)

if @dataset.organizations
  #json.organization @dataset.organization.name
end

if @dataset.characteristic
  json.characteristic @dataset.characteristic.name
end

if @dataset.author
  json.author @dataset.author.name
  json.author_email @dataset.author.email
end

if @dataset.maintainer
  json.maintainer @dataset.maintainer.name
  json.maintainer_email @dataset.maintainer.email
end

json.categories @dataset.categories.reject{ |c| c.blank? } unless @dataset.categories.blank?


json.distributions @dataset.distributions do |distribution|
  json.url         distribution.uri
  json.name        distribution.name
  json.description distribution.description
  json.format      distribution.format
end

json.basename @dataset.title.downcase.gsub(' ', '-')
